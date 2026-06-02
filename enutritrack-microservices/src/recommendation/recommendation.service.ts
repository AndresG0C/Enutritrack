import {
  Injectable,
  Logger,
  NotFoundException,
  BadRequestException,
  InternalServerErrorException,
} from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository, MoreThan } from 'typeorm';
import { GoogleGenAI } from '@google/genai';
import { Recommendation } from './models/recommendation.model';
import { RecommendationType } from './models/tipos_recomendacion.model';
import { RecommendationData } from './models/recomendacion_datos';
import {
  CreateRecommendationDto,
  CreateAIRecommendationDto,
  UpdateRecommendationDto,
  CreateRecommendationTypeDto,
  UpdateRecommendationTypeDto,
} from './dto/create-recommendation.dto';

@Injectable()
export class RecommendationsService {
  private readonly logger = new Logger(RecommendationsService.name);
  private ai: GoogleGenAI | null = null;
  private aiEnabled: boolean = false;

  constructor(
    @InjectRepository(Recommendation)
    private recommendationRepository: Repository<Recommendation>,
    @InjectRepository(RecommendationType)
    private typeRepository: Repository<RecommendationType>,
    @InjectRepository(RecommendationData)
    private dataRepository: Repository<RecommendationData>,
  ) {
    this.initializeAI();
  }

  // ─────────────────────────────────────────────
  //  INICIALIZACIÓN DE IA
  // ─────────────────────────────────────────────

  private initializeAI(): void {
    const apiKey = process.env.GEMINI_API_KEY;

    if (!apiKey) {
      this.logger.warn(
        '⚠️  IA deshabilitada — GEMINI_API_KEY no está configurada en las variables de entorno.',
      );
      this.aiEnabled = false;
      return;
    }

    this.ai = new GoogleGenAI({ apiKey });
    this.aiEnabled = true;
    this.logger.log('🔑 GEMINI_API_KEY detectada — probando conexión...');
    this.testAIConnection();
  }

  private async testAIConnection(): Promise<void> {
    try {
      const response = await this.ai!.models.generateContent({
        model: 'gemini-2.5-flash',
        contents: "Responde únicamente con 'OK'",
      });
      this.logger.log(`✅ Conexión con Gemini exitosa: ${response.text?.trim()}`);
    } catch (error) {
      this.logger.error(
        `❌ No se pudo conectar con Gemini: ${error.message}`,
      );
      this.aiEnabled = false;
    }
  }

  // ─────────────────────────────────────────────
  //  TIPOS DE RECOMENDACIÓN
  // ─────────────────────────────────────────────

  async createType(
    createTypeDto: CreateRecommendationTypeDto,
  ): Promise<RecommendationType> {
    try {
      const type = this.typeRepository.create(createTypeDto);
      return await this.typeRepository.save(type);
    } catch (error) {
      this.logger.error(`Error al crear tipo de recomendación: ${error.message}`);
      throw new BadRequestException('Error al crear el tipo de recomendación');
    }
  }

  async findAllTypes(): Promise<RecommendationType[]> {
    return this.typeRepository.find({ order: { nombre: 'ASC' } });
  }

  async findTypeById(id: string): Promise<RecommendationType> {
    const type = await this.typeRepository.findOne({ where: { id } });
    if (!type) throw new NotFoundException('Tipo de recomendación no encontrado');
    return type;
  }

  async updateType(
    id: string,
    updateTypeDto: UpdateRecommendationTypeDto,
  ): Promise<RecommendationType> {
    const type = await this.findTypeById(id);
    Object.assign(type, updateTypeDto);
    return this.typeRepository.save(type);
  }

  async deleteType(id: string): Promise<void> {
    const result = await this.typeRepository.delete(id);
    if (result.affected === 0)
      throw new NotFoundException('Tipo de recomendación no encontrado');
  }

  // ─────────────────────────────────────────────
  //  RECOMENDACIONES
  // ─────────────────────────────────────────────

  async create(createDto: CreateRecommendationDto): Promise<Recommendation> {
    try {
      const recommendation = this.recommendationRepository.create(createDto);
      return await this.recommendationRepository.save(recommendation);
    } catch (error) {
      this.logger.error(`Error al crear recomendación: ${error.message}`);
      throw new BadRequestException('Error al crear la recomendación');
    }
  }

  async createWithAI(
    createAIDto: CreateAIRecommendationDto,
  ): Promise<Recommendation> {
    // Verificar disponibilidad de IA antes de continuar
    if (!this.aiEnabled) {
      throw new InternalServerErrorException(
        'El servicio de IA no está disponible. Verifica que GEMINI_API_KEY esté configurada correctamente.',
      );
    }

    const recommendationType = await this.typeRepository.findOne({
      where: { id: createAIDto.tipo_recomendacion_id },
    });

    if (!recommendationType) {
      throw new NotFoundException('Tipo de recomendación no encontrado');
    }

    const userData = await this.getUserData(createAIDto.usuario_id);

    const aiContent = await this.generateAIContent(
      recommendationType,
      userData,
      createAIDto.contexto_adicional,
    );

    const recommendation = this.recommendationRepository.create({
      usuario_id: createAIDto.usuario_id,
      tipo_recomendacion_id: createAIDto.tipo_recomendacion_id,
      contenido: aiContent,
      prioridad: createAIDto.prioridad ?? 'media',
      vigencia_hasta:
        createAIDto.vigencia_hasta ??
        this.calculateDefaultExpiry(recommendationType.nombre),
      activa: true,
    });

    return this.recommendationRepository.save(recommendation);
  }

  // ─────────────────────────────────────────────
  //  GENERACIÓN DE CONTENIDO CON IA
  // ─────────────────────────────────────────────

  private async generateAIContent(
    type: RecommendationType,
    userData: any,
    additionalContext?: string,
  ): Promise<string> {
    const prompt = this.buildPrompt(type, userData, additionalContext);

    this.logger.log('🚀 Generando recomendación con Gemini 2.5 Flash...');

    try {
      const response = await this.ai!.models.generateContent({
        model: 'gemini-2.5-flash',
        contents: prompt,
      });

      const text = response.text?.trim();

      if (!text) {
        throw new Error('Gemini devolvió una respuesta vacía');
      }

      this.logger.log('✅ Recomendación generada exitosamente por IA');
      return text;
    } catch (error) {
      this.logger.error(`❌ Error al generar contenido con IA: ${error.message}`);

      // Marcar IA como no disponible si el error es de autenticación/permisos
      if (error?.status === 403 || error?.code === 403) {
        this.aiEnabled = false;
        this.logger.error(
          '🔒 IA deshabilitada por error de permisos (403). Verifica que la API key sea válida y tenga acceso a Gemini.',
        );
      }

      throw new InternalServerErrorException(
        `No se pudo generar la recomendación con IA: ${error.message}`,
      );
    }
  }

  private buildPrompt(
    type: RecommendationType,
    userData: any,
    additionalContext?: string,
  ): string {
    return `
Eres un asistente médico especializado en ${type.nombre}.
Genera una recomendación personalizada en español para el siguiente paciente.

Datos del paciente:
- Nombre: ${userData.nombre}
- Edad: ${userData.edad} años
- Género: ${userData.genero}
- Altura: ${userData.altura} cm
- Peso actual: ${userData.peso_actual} kg
- Objetivo de peso: ${userData.peso_objetivo} kg
- Nivel de actividad: ${userData.nivel_actividad}
${additionalContext ? `\nContexto adicional: ${additionalContext}` : ''}

La recomendación debe:
- Ser práctica y aplicable en la vida diaria
- Estar basada en evidencia científica
- Estar personalizada para este paciente
- Ser clara y fácil de entender
- Incluir consejos específicos y medibles
- Usar un tono profesional pero cercano

Formato de respuesta:
- Inicia con un título descriptivo
- Organiza la información en secciones claras
- Usa emojis relevantes
- Incluye horarios o frecuencias cuando aplique
- Finaliza con recordatorios importantes
`.trim();
  }

  // ─────────────────────────────────────────────
  //  HELPERS
  // ─────────────────────────────────────────────

  private async getUserData(userId: string): Promise<any> {
    // TODO: reemplazar con consulta real a la base de datos de usuarios
    // Ejemplo: return this.usersService.findOne(userId);
    return {
      nombre: 'Paciente',
      edad: 35,
      genero: 'No especificado',
      altura: 170,
      peso_actual: 70,
      peso_objetivo: 65,
      nivel_actividad: 'moderado',
    };
  }

  private calculateDefaultExpiry(typeName: string): Date {
    const expiry = new Date();
    const type = typeName.toLowerCase();
    if (type.includes('nutrición') || type.includes('nutrition'))
      expiry.setDate(expiry.getDate() + 30);
    else if (type.includes('ejercicio') || type.includes('exercise'))
      expiry.setDate(expiry.getDate() + 14);
    else if (type.includes('salud') || type.includes('medical'))
      expiry.setDate(expiry.getDate() + 90);
    else
      expiry.setDate(expiry.getDate() + 7);
    return expiry;
  }

  // ─────────────────────────────────────────────
  //  CRUD DE RECOMENDACIONES
  // ─────────────────────────────────────────────

  async findAllByUser(
    userId: string,
    includeInactive: boolean = false,
  ): Promise<Recommendation[]> {
    const where: any = { usuario_id: userId };
    if (!includeInactive) {
      where.activa = true;
      where.vigencia_hasta = MoreThan(new Date());
    }
    return this.recommendationRepository.find({
      where,
      relations: ['tipo_recomendacion', 'datos'],
      order: { fecha_generacion: 'DESC' },
    });
  }

  async findActiveByUser(userId: string): Promise<Recommendation[]> {
    return this.recommendationRepository.find({
      where: {
        usuario_id: userId,
        activa: true,
        vigencia_hasta: MoreThan(new Date()),
      },
      relations: ['tipo_recomendacion', 'datos'],
      order: { fecha_generacion: 'DESC' },
    });
  }

  async findOne(id: string): Promise<Recommendation> {
    const recommendation = await this.recommendationRepository.findOne({
      where: { id },
      relations: ['tipo_recomendacion', 'datos'],
    });
    if (!recommendation)
      throw new NotFoundException('Recomendación no encontrada');
    return recommendation;
  }

  async update(
    id: string,
    updateDto: UpdateRecommendationDto,
  ): Promise<Recommendation> {
    const recommendation = await this.findOne(id);
    Object.assign(recommendation, updateDto);
    return this.recommendationRepository.save(recommendation);
  }

  async deactivate(id: string): Promise<Recommendation> {
    const recommendation = await this.findOne(id);
    recommendation.activa = false;
    return this.recommendationRepository.save(recommendation);
  }

  async delete(id: string): Promise<void> {
    const result = await this.recommendationRepository.delete(id);
    if (result.affected === 0)
      throw new NotFoundException('Recomendación no encontrada');
  }

  async addRecommendationData(
    recommendationId: string,
    clave: string,
    valor: string,
    tipo_dato?: string,
  ): Promise<RecommendationData> {
    const data = this.dataRepository.create({
      recomendacion_id: recommendationId,
      clave,
      valor,
      tipo_dato,
    });
    return this.dataRepository.save(data);
  }

  // ─────────────────────────────────────────────
  //  DIAGNÓSTICO
  // ─────────────────────────────────────────────

  async healthCheck() {
    return {
      status: 'online',
      timestamp: new Date().toISOString(),
      service: process.env.SERVICE_NAME || 'Microservicio de recomendaciones',
      version: process.env.APP_VERSION || '1.2.0',
      ai: {
        status: this.aiEnabled ? 'connected' : 'disabled',
        provider: 'Google Gemini',
        model: 'gemini-2.5-flash',
        message: this.aiEnabled
          ? 'IA operativa'
          : 'IA no disponible — verifica GEMINI_API_KEY en las variables de entorno',
      },
    };
  }

  async testAI(): Promise<any> {
    if (!this.aiEnabled) {
      return {
        status: 'disabled',
        message:
          'IA no está habilitada. Verifica que GEMINI_API_KEY esté definida en las variables de entorno.',
        timestamp: new Date().toISOString(),
      };
    }

    try {
      const response = await this.ai!.models.generateContent({
        model: 'gemini-2.5-flash',
        contents: 'Confirma brevemente que la IA está funcionando.',
      });

      return {
        status: 'success',
        message: 'Conexión con Gemini 2.5 Flash exitosa',
        response: response.text?.trim(),
        timestamp: new Date().toISOString(),
      };
    } catch (error) {
      return {
        status: 'error',
        message: error.message,
        timestamp: new Date().toISOString(),
      };
    }
  }
}
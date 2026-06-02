import { Injectable, NotFoundException, BadRequestException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { Alerta } from './models/alertas.model';
import { AlertaAccion } from '../alertas-acciones/models/alertas-acciones.model';
import { CreateAlertaDto } from './dto/create-alertas.dto';
import { UpdateAlertaDto } from './dto/update-alertas.dto';

@Injectable()
export class AlertasService {
  constructor(
    @InjectRepository(Alerta)
    private alertaRepository: Repository<Alerta>,
    @InjectRepository(AlertaAccion)
    private alertaAccionRepository: Repository<AlertaAccion>,
  ) {}

  async create(createAlertaDto: CreateAlertaDto): Promise<Alerta> {
    const alerta = this.alertaRepository.create(createAlertaDto);
    return await this.alertaRepository.save(alerta);
  }

  async findAll(): Promise<Alerta[]> {
    return await this.alertaRepository.find({
      relations: [
        'usuario', 
        'doctor', 
        'tipo_alerta', 
        'tipo_alerta.categoria',
        'nivel_prioridad', 
        'estado_alerta'
      ],
      order: { fecha_deteccion: 'DESC' }
    });
  }

  async findByUser(userId: string): Promise<Alerta[]> {
    return await this.alertaRepository.find({
      where: { usuario_id: userId },
      relations: [
        'usuario', 
        'doctor', 
        'tipo_alerta', 
        'tipo_alerta.categoria',
        'nivel_prioridad', 
        'estado_alerta'
      ],
      order: { fecha_deteccion: 'DESC' }
    });
  }

  async findByDoctor(doctorId: string): Promise<Alerta[]> {
    return await this.alertaRepository.find({
      where: { doctor_id: doctorId },
      relations: [
        'usuario', 
        'doctor', 
        'tipo_alerta', 
        'tipo_alerta.categoria',
        'nivel_prioridad', 
        'estado_alerta'
      ],
      order: { fecha_deteccion: 'DESC' }
    });
  }

  async findOne(id: string): Promise<Alerta | null> {
    const alerta = await this.alertaRepository.findOne({
      where: { id },
      relations: [
        'usuario', 
        'usuario.cuenta',
        'doctor', 
        'tipo_alerta', 
        'tipo_alerta.categoria',
        'nivel_prioridad', 
        'estado_alerta',
        'resuelta_por_doctor'
      ]
    });

    if (!alerta) {
      return null;
    }

    // Buscar acciones relacionadas
    const acciones = await this.alertaAccionRepository.find({
      where: { alerta_id: id },
      relations: ['doctor'],
      order: { fecha_accion: 'DESC' }
    });

    return {
      ...alerta,
      acciones
    } as any;
  }

  async update(id: string, updateAlertaDto: UpdateAlertaDto): Promise<Alerta | null> {
    const result = await this.alertaRepository.update(id, updateAlertaDto);
    if (result.affected === 0) {
      throw new NotFoundException('Alerta no encontrada');
    }
    return await this.findOne(id);
  }

  async addAction(alertaId: string, doctorId: string, accion: string, descripcion?: string): Promise<AlertaAccion> {
    const alerta = await this.findOne(alertaId);
    if (!alerta) {
      throw new NotFoundException('Alerta no encontrada');
    }

    const alertaAccion = this.alertaAccionRepository.create({
      alerta_id: alertaId,
      doctor_id: doctorId,
      accion_tomada: accion,
      descripcion
    });

    return await this.alertaAccionRepository.save(alertaAccion);
  }

  async resolve(id: string, doctorId: string, notasResolucion: string): Promise<Alerta | null> {
    const updateData = {
      fecha_resolucion: new Date().toISOString(),
      resuelta_por: doctorId,
      notas_resolucion: notasResolucion
    };

    await this.update(id, updateData);
    await this.addAction(id, doctorId, 'Alerta resuelta', notasResolucion);
    
    return await this.findOne(id);
  }

  async remove(id: string): Promise<void> {
    // Primero eliminar acciones relacionadas
    await this.alertaAccionRepository.delete({ alerta_id: id });
    
    // Luego eliminar la alerta
    const result = await this.alertaRepository.delete(id);
    if (result.affected === 0) {
      throw new NotFoundException('Alerta no encontrada');
    }
  }
}

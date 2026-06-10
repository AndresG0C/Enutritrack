import {
  Controller,
  Get,
  Post,
  Body,
  Patch,
  Param,
  Delete,
  Query,
  UseGuards,
  Request,
  HttpCode,
} from '@nestjs/common';
import {
  ApiTags,
  ApiOperation,
  ApiResponse,
  ApiBody,
  ApiParam,
  ApiQuery,
  ApiBearerAuth,
} from '@nestjs/swagger';
import { CitasMedicasService } from './citas-medicas.service';
import { CreateCitaMedicaDto } from './dto/create-cita-medica.dto';
import { UpdateCitaMedicaDto } from './dto/update-cita-medica.dto';
import { CitasQueryDto } from './dto/citas-query.dto';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';

@ApiTags('Medical Appointments')
@ApiBearerAuth()
@Controller('citas-medicas')

export class CitasMedicasController {
  constructor(private readonly citasMedicasService: CitasMedicasService) { }

  @Post()
  @UseGuards(JwtAuthGuard)
  @ApiOperation({
    summary: 'Crear nueva cita médica',
    description:
      'Crea una nueva cita médica para un paciente. Solo disponible para doctores autenticados.',
  })
  @ApiBody({
    type: CreateCitaMedicaDto,
    examples: {
      json: {
        summary: 'Ejemplo JSON - Cita completa',
        value: {
          usuarioId: '123e4567-e89b-12d3-a456-426614174000',
          tipoConsultaId: 'a1b2c3d4-e5f6-7890-abcd-ef1234567890',
          estadoCitaId: 'b2c3d4e5-f6a7-8901-bcde-f12345678901',
          fechaHoraProgramada: '2024-01-20T10:00:00.000Z',
          motivo: 'Control de presión arterial',
          observaciones: 'Paciente con historial de hipertensión',
        },
      },
      xml: {
        summary: 'Ejemplo XML - Cita básica',
        value: `<?xml version="1.0" encoding="UTF-8"?>
<CreateCitaMedicaDto>
  <usuarioId>123e4567-e89b-12d3-a456-426614174000</usuarioId>
  <tipoConsultaId>a1b2c3d4-e5f6-7890-abcd-ef1234567890</tipoConsultaId>
  <estadoCitaId>b2c3d4e5-f6a7-8901-bcde-f12345678901</estadoCitaId>
  <fechaHoraProgramada>2024-01-20T10:00:00.000Z</fechaHoraProgramada>
  <motivo>Consulta de rutina</motivo>
</CreateCitaMedicaDto>`,
      },
    },
  })
  @ApiResponse({
    status: 201,
    description: 'Cita médica creada exitosamente',
    schema: {
      example: {
        id: '223e4567-e89b-12d3-a456-426614174000',
        fechaHoraProgramada: '2024-01-20T10:00:00.000Z',
        motivo: 'Control de presión arterial',
        observaciones: 'Paciente con historial de hipertensión',
        usuario: {
          id: '123e4567-e89b-12d3-a456-426614174000',
          nombre: 'Juan Pérez',
          cuenta: { email: 'juan.perez@ejemplo.com' },
        },
        doctor: {
          id: '323e4567-e89b-12d3-a456-426614174000',
          nombre: 'Dr. Carlos López',
          especialidad: { nombre: 'Cardiología' },
        },
        tipoConsulta: {
          id: 'a1b2c3d4-e5f6-7890-abcd-ef1234567890',
          nombre: 'Consulta de control',
          duracionMinutos: 30,
        },
        estadoCita: {
          id: 'b2c3d4e5-f6a7-8901-bcde-f12345678901',
          nombre: 'Programada',
          esFinal: false,
        },
      },
    },
  })
  @ApiResponse({
    status: 404,
    description: 'Paciente, doctor o tipo de consulta no encontrado',
  })
  @ApiResponse({
    status: 409,
    description: 'Conflicto de horario con otra cita',
  })
  @ApiResponse({
    status: 401,
    description: 'No autorizado - Token JWT requerido',
  })
  create(@Body() createCitaMedicaDto: CreateCitaMedicaDto, @Request() req) {
    const doctorId = req.user?.userId || req.user?.sub;
    return this.citasMedicasService.create(createCitaMedicaDto, doctorId);
  }

  @Get()
  @UseGuards(JwtAuthGuard)
  @ApiOperation({
    summary: 'Obtener todas las citas médicas',
    description:
      'Retorna una lista paginada de citas médicas con opciones de filtrado',
  })
  @ApiQuery({
    name: 'doctorId',
    required: false,
    type: String,
    description: 'Filtrar por ID del doctor',
    example: '323e4567-e89b-12d3-a456-426614174000',
  })
  @ApiQuery({
    name: 'usuarioId',
    required: false,
    type: String,
    description: 'Filtrar por ID del paciente',
    example: '123e4567-e89b-12d3-a456-426614174000',
  })
  @ApiQuery({
    name: 'fechaInicio',
    required: false,
    type: String,
    description: 'Fecha de inicio para filtrar (formato ISO)',
    example: '2024-01-15',
  })
  @ApiQuery({
    name: 'fechaFin',
    required: false,
    type: String,
    description: 'Fecha de fin para filtrar (formato ISO)',
    example: '2024-01-20',
  })
  @ApiQuery({
    name: 'estadoCitaId',
    required: false,
    type: String,
    description: 'Filtrar por estado de cita',
    example: 'b2c3d4e5-f6a7-8901-bcde-f12345678901',
  })
  @ApiQuery({
    name: 'search',
    required: false,
    type: String,
    description: 'Búsqueda por nombre de paciente, email o motivo',
    example: 'Juan',
  })
  @ApiQuery({
    name: 'page',
    required: false,
    type: String,
    description: 'Página para paginación (por defecto: 1)',
    example: '1',
  })
  @ApiQuery({
    name: 'limit',
    required: false,
    type: String,
    description: 'Límite de resultados por página (por defecto: 10)',
    example: '10',
  })
  @ApiResponse({
    status: 200,
    description: 'Lista de citas médicas obtenida exitosamente',
    schema: {
      example: {
        citas: [
          {
            id: '223e4567-e89b-12d3-a456-426614174000',
            fechaHoraProgramada: '2024-01-20T10:00:00.000Z',
            motivo: 'Control de presión arterial',
            usuario: {
              id: '123e4567-e89b-12d3-a456-426614174000',
              nombre: 'Juan Pérez',
              cuenta: { email: 'juan.perez@ejemplo.com' },
            },
            doctor: {
              id: '323e4567-e89b-12d3-a456-426614174000',
              nombre: 'Dr. Carlos López',
            },
            tipoConsulta: { nombre: 'Consulta de control' },
            estadoCita: { nombre: 'Programada' },
          },
        ],
        total: 1,
        page: 1,
        limit: 10,
        totalPages: 1,
      },
    },
  })
  @ApiResponse({
    status: 401,
    description: 'No autorizado - Token JWT requerido',
  })
  findAll(@Query() query: CitasQueryDto) {
    return this.citasMedicasService.findAll(query);
  }

  @Get('mis-citas')
  @UseGuards(JwtAuthGuard)
  @ApiOperation({
    summary: 'Obtener citas del doctor autenticado',
    description: 'Retorna las citas médicas del doctor actualmente autenticado',
  })
  @ApiQuery({
    name: 'fechaInicio',
    required: false,
    type: String,
    description: 'Fecha de inicio para filtrar',
  })
  @ApiQuery({
    name: 'fechaFin',
    required: false,
    type: String,
    description: 'Fecha de fin para filtrar',
  })
  @ApiQuery({
    name: 'estadoCitaId',
    required: false,
    type: String,
    description: 'Filtrar por estado de cita',
  })
  @ApiQuery({
    name: 'search',
    required: false,
    type: String,
    description: 'Búsqueda por nombre de paciente o motivo',
  })
  @ApiQuery({
    name: 'page',
    required: false,
    type: String,
    description: 'Página para paginación',
  })
  @ApiQuery({
    name: 'limit',
    required: false,
    type: String,
    description: 'Límite de resultados por página',
  })
  @ApiResponse({
    status: 200,
    description: 'Citas del doctor obtenidas exitosamente',
  })
  @ApiResponse({
    status: 401,
    description: 'No autorizado - Token JWT requerido',
  })
  findMisCitas(@Query() query: CitasQueryDto, @Request() req) {
    return this.citasMedicasService.getCitasPorDoctor(req.user.doctorId, query);
  }

  @Get('estados')
  @UseGuards(JwtAuthGuard)
  @ApiOperation({
    summary: 'Obtener estados de cita disponibles',
    description:
      'Retorna la lista de todos los estados posibles para una cita médica',
  })
  @ApiResponse({
    status: 200,
    description: 'Lista de estados de cita obtenida exitosamente',
    schema: {
      example: [
        {
          id: 'b2c3d4e5-f6a7-8901-bcde-f12345678901',
          nombre: 'Programada',
          descripcion: 'Cita programada pero no iniciada',
          esFinal: false,
        },
        {
          id: 'c3d4e5f6-a7b8-9012-cdef-123456789012',
          nombre: 'En Proceso',
          descripcion: 'Cita en curso',
          esFinal: false,
        },
        {
          id: 'd4e5f6a7-b8c9-0123-defg-234567890123',
          nombre: 'Completada',
          descripcion: 'Cita finalizada exitosamente',
          esFinal: true,
        },
        {
          id: 'e5f6a7b8-c9d0-1234-efgh-345678901234',
          nombre: 'Cancelada',
          descripcion: 'Cita cancelada',
          esFinal: true,
        },
      ],
    },
  })
  getEstadosCita() {
    return this.citasMedicasService.getEstadosCita();
  }

  @Get('tipos-consulta')
  @UseGuards(JwtAuthGuard)
  @ApiOperation({
    summary: 'Obtener tipos de consulta disponibles',
    description:
      'Retorna la lista de todos los tipos de consulta médica disponibles',
  })
  @ApiResponse({
    status: 200,
    description: 'Lista de tipos de consulta obtenida exitosamente',
    schema: {
      example: [
        {
          id: 'a1b2c3d4-e5f6-7890-abcd-ef1234567890',
          nombre: 'Consulta general',
          duracionMinutos: 30,
          descripcion: 'Consulta médica general de rutina',
        },
        {
          id: 'f6a7b8c9-d0e1-2345-fghi-456789012345',
          nombre: 'Consulta especializada',
          duracionMinutos: 45,
          descripcion: 'Consulta con especialista',
        },
        {
          id: 'g7b8c9d0-e1f2-3456-ghij-567890123456',
          nombre: 'Control de seguimiento',
          duracionMinutos: 20,
          descripcion: 'Control de seguimiento de tratamiento',
        },
      ],
    },
  })
  getTiposConsulta() {
    return this.citasMedicasService.getTiposConsulta();
  }

  @Get(':id')
  @UseGuards(JwtAuthGuard)
  @ApiOperation({
    summary: 'Obtener cita médica por ID',
    description:
      'Retorna la información completa de una cita médica específica',
  })
  @ApiParam({
    name: 'id',
    type: String,
    description: 'ID de la cita médica',
    example: '223e4567-e89b-12d3-a456-426614174000',
  })
  @ApiResponse({
    status: 200,
    description: 'Cita médica encontrada',
    schema: {
      example: {
        id: '223e4567-e89b-12d3-a456-426614174000',
        fechaHoraProgramada: '2024-01-20T10:00:00.000Z',
        fechaHoraInicio: null,
        fechaHoraFin: null,
        motivo: 'Control de presión arterial',
        observaciones: 'Paciente con historial de hipertensión',
        diagnostico: null,
        tratamientoRecomendado: null,
        proximaCitaSugerida: null,
        usuario: {
          id: '123e4567-e89b-12d3-a456-426614174000',
          nombre: 'Juan Pérez',
          fecha_nacimiento: '1990-05-15T00:00:00.000Z',
          genero: { nombre: 'Masculino' },
          cuenta: { email: 'juan.perez@ejemplo.com' },
        },
        doctor: {
          id: '323e4567-e89b-12d3-a456-426614174000',
          nombre: 'Dr. Carlos López',
          cedula_profesional: '1234567',
          especialidad: { nombre: 'Cardiología' },
          cuenta: { email: 'carlos.lopez@clinica.com' },
        },
        tipoConsulta: {
          id: 'a1b2c3d4-e5f6-7890-abcd-ef1234567890',
          nombre: 'Consulta de control',
          duracionMinutos: 30,
        },
        estadoCita: {
          id: 'b2c3d4e5-f6a7-8901-bcde-f12345678901',
          nombre: 'Programada',
          esFinal: false,
        },
        created_at: '2024-01-15T10:30:00.000Z',
        updated_at: '2024-01-15T10:30:00.000Z',
      },
    },
  })
  @ApiResponse({
    status: 404,
    description: 'Cita médica no encontrada',
  })
  @ApiResponse({
    status: 401,
    description: 'No autorizado - Token JWT requerido',
  })
  findOne(@Param('id') id: string) {
    return this.citasMedicasService.findOne(id);
  }

  @Patch(':id')
  @UseGuards(JwtAuthGuard)
  @ApiOperation({
    summary: 'Actualizar cita médica',
    description: 'Actualiza la información de una cita médica existente',
  })
  @ApiParam({
    name: 'id',
    type: String,
    description: 'ID de la cita médica a actualizar',
    example: '223e4567-e89b-12d3-a456-426614174000',
  })
  @ApiBody({
    type: UpdateCitaMedicaDto,
    examples: {
      json: {
        summary: 'Ejemplo JSON - Actualización completa',
        value: {
          tipoConsultaId: 'f6a7b8c9-d0e1-2345-fghi-456789012345',
          estadoCitaId: 'c3d4e5f6-a7b8-9012-cdef-123456789012',
          fechaHoraProgramada: '2024-01-20T11:00:00.000Z',
          motivo: 'Control de presión arterial - reprogramada',
          observaciones: 'Paciente requiere ajuste de medicación',
        },
      },
      xml: {
        summary: 'Ejemplo XML - Actualización parcial',
        value: `<?xml version="1.0" encoding="UTF-8"?>
<UpdateCitaMedicaDto>
  <fechaHoraProgramada>2024-01-20T11:00:00.000Z</fechaHoraProgramada>
  <motivo>Control de presión arterial - reprogramada</motivo>
  <observaciones>Paciente requiere ajuste de medicación</observaciones>
</UpdateCitaMedicaDto>`,
      },
    },
  })
  @ApiResponse({
    status: 200,
    description: 'Cita médica actualizada exitosamente',
  })
  @ApiResponse({
    status: 404,
    description: 'Cita médica no encontrada',
  })
  @ApiResponse({
    status: 409,
    description: 'Conflicto de horario con otra cita',
  })
  @ApiResponse({
    status: 401,
    description: 'No autorizado - Token JWT requerido',
  })
  update(
    @Param('id') id: string,
    @Body() updateCitaMedicaDto: UpdateCitaMedicaDto,
  ) {
    return this.citasMedicasService.update(id, updateCitaMedicaDto);
  }

  @Patch(':id/estado/:estadoCitaId')
  @UseGuards(JwtAuthGuard)
  @ApiOperation({
    summary: 'Cambiar estado de cita',
    description: 'Cambia el estado de una cita médica específica',
  })
  @ApiParam({
    name: 'id',
    type: String,
    description: 'ID de la cita médica',
    example: '223e4567-e89b-12d3-a456-426614174000',
  })
  @ApiParam({
    name: 'estadoCitaId',
    type: String,
    description: 'ID del nuevo estado de cita',
    example: 'c3d4e5f6-a7b8-9012-cdef-123456789012',
  })
  @ApiResponse({
    status: 200,
    description: 'Estado de cita cambiado exitosamente',
  })
  @ApiResponse({
    status: 404,
    description: 'Cita médica o estado no encontrado',
  })
  @ApiResponse({
    status: 401,
    description: 'No autorizado - Token JWT requerido',
  })
  cambiarEstado(
    @Param('id') id: string,
    @Param('estadoCitaId') estadoCitaId: string,
  ) {
    return this.citasMedicasService.cambiarEstadoCita(id, estadoCitaId);
  }

  @Delete(':id')
  @UseGuards(JwtAuthGuard)
  @ApiOperation({
    summary: 'Eliminar cita médica',
    description:
      'Elimina una cita médica del sistema. Solo se pueden eliminar citas que no estén en proceso o finalizadas.',
  })
  @ApiParam({
    name: 'id',
    type: String,
    description: 'ID de la cita médica a eliminar',
    example: '223e4567-e89b-12d3-a456-426614174000',
  })
  @ApiResponse({
    status: 200,
    description: 'Cita médica eliminada exitosamente',
    schema: {
      example: {
        message: 'Cita médica eliminada correctamente',
      },
    },
  })
  @ApiResponse({
    status: 404,
    description: 'Cita médica no encontrada',
  })
  @ApiResponse({
    status: 400,
    description: 'No se puede eliminar una cita en proceso o finalizada',
  })
  @ApiResponse({
    status: 401,
    description: 'No autorizado - Token JWT requerido',
  })
  remove(@Param('id') id: string) {
    return this.citasMedicasService.remove(id);
  }

  @Get('health/check')
  @HttpCode(200)
  @ApiOperation({
    summary: 'Health Check',
    description: 'Verifica el estado del microservicio de citas médicas',
  })
  @ApiResponse({
    status: 200,
    description: 'Microservicio funcionando correctamente',
    schema: {
      example: {
        status: 'online',
        timestamp: '2024-01-15T10:30:00.000Z',
        uptime: 3600,
        service: 'Microservicio de citas medicas',
        version: '1.1.0',
      },
    },
  })
  healthCheck() {
    return this.citasMedicasService.healthCheck();
  }
}

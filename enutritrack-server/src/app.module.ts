import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { ConfigModule } from '@nestjs/config';
import { AuthModule } from './auth/auth.module';
import { CuentasModule } from './cuentas/cuentas.module';
import { PerfilAdminModule } from './admin/admin.module';
import { PerfilDoctorModule } from './doctor/doctor.module';
import { PerfilUsuarioModule } from './users/user.module';
import { TiposActividadModule } from './tipo-actividad/tipo-actividad.module';
import { AlimentosModule } from './alimento/alimento.module';
import { TiposRecomendacionModule } from './tipo-recomendacion/tipo-recomendacion.module';
import { ObjetivoUsuarioModule } from './objetivo-usuario/objetivo-usuario.module';
import { HistorialPesoModule } from './historial-peso/historial-peso.module';
import { CondicionesMedicasModule } from './condicion-medica/condicion-medica.module';
import { AlergiasModule } from './alergia/alergia.module';
import { MedicamentosModule } from './medicamento/medicamento.module';
import { PhysicalActivityModule } from './activity/activity.module';
import { RegistroComidaModule } from './nutrition/nutrition.module';
import { RegistroComidaItemsModule } from './registro-comida-item/registro-comida-item.module';
import { RecomendacionModule } from './recommendation/recommendation.module';
import { RecomendacionDatosModule } from './recomendacion-dato/recomendacion-dato.module';
import { EspecialidadModule } from './especialidad/especialidad.module';
import { GeneroModule } from './genero/genero.module';
import { TiposConsultaModule } from './tipos-consulta/tipos-consulta.module';
import { EstadosCitaModule } from './estados-cita/estados-cita.module';
import { CategoriasAlertaModule } from './categorias-alerta/categorias-alerta.module';
import { NivelesPrioridadAlertaModule } from './niveles-prioridad-alerta/niveles-prioridad-alerta.module';
import { EstadosAlertaModule } from './estados-alerta/estados-alerta.module';
import { TiposAlertaModule } from './tipos-alerta/tipos-alerta.module';
import { CitasMedicasModule } from './citas-medicas/citas-medicas.module';
import { AlertasModule } from './alertas/alertas.module';
import { AlertasAccionesModule } from './alertas-acciones/alertas-acciones.module';
import { ConfiguracionAlertasAutomaticasModule } from './configuracion-alertas-automaticas/configuracion-alertas-automaticas.module';
import { CouchbaseAlertsCitasModule } from './couchbase-alerts-citas/couchbase-alerts-citas.module';
import { MedicalHistoryModule } from './medical-history/medical-history.module';
import { AppController } from './app.controller';

@Module({
  imports: [
    ConfigModule.forRoot({
      isGlobal: true,
    }),
    TypeOrmModule.forRoot({
      type: 'postgres',
      host: process.env.DB_HOST ?? 'localhost',
      port: parseInt(process.env.DB_PORT ?? '5433', 10),
      username: 'enutritrack',
      password: 'enutritrack2024',
      database: 'enutritrack',
      entities: [__dirname + '/**/*.entity{.ts,.js}'],
      synchronize: false, // Usar migraciones en lugar de sync
      migrations: ['src/migration/*.ts'],
      autoLoadEntities: true,
    }),
    AuthModule,
    CuentasModule,
    PerfilAdminModule,
    PerfilDoctorModule,
    PerfilUsuarioModule,
    TiposActividadModule,
    AlimentosModule,
    TiposRecomendacionModule,
    ObjetivoUsuarioModule,
    HistorialPesoModule,
    CondicionesMedicasModule,
    AlergiasModule,
    MedicamentosModule,
    MedicalHistoryModule,
    PhysicalActivityModule,
    RegistroComidaModule,
    RegistroComidaItemsModule,
    RecomendacionModule,
    RecomendacionDatosModule,
    EspecialidadModule,
    GeneroModule,
    TiposConsultaModule,
    EstadosCitaModule,
    CategoriasAlertaModule,
    NivelesPrioridadAlertaModule,
    EstadosAlertaModule,
    TiposAlertaModule,
    CitasMedicasModule,
    AlertasModule,
    AlertasAccionesModule,
    ConfiguracionAlertasAutomaticasModule,
    CouchbaseAlertsCitasModule,
  ],
  controllers: [AppController],
})
export class AppModule { }

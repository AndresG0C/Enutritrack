// src/app.module.ts
import { Module } from '@nestjs/common';
import { ConfigModule } from '@nestjs/config';
import { UserModule } from './users/users.module';
import { NutritionModule } from './nutrition/nutrition.module';
import { MedicalHistoryModule } from './medical-history/medical-history.module';
import { PhysicalActivityModule } from './activity/activity.module';
import { RecommendationModule } from './recommendation/recommendation.module';
import { AuthModule } from './auth/auth.module';
import { TypeOrmModule } from '@nestjs/typeorm';
import { DoctorModule } from './doctor/doctor.module';
import { CitasMedicasModule } from './citas/citas-medicas.module';
import { AlertsModule } from './alertas/alertas.module';
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
      username: process.env.DB_USER ?? 'enutritrack',      // ✅ Usar variable
      password: process.env.DB_PASSWORD ?? 'enutritrack2024', // ✅ Usar variable
      database: process.env.DB_NAME ?? 'enutritrack',      // ✅ Usar variable
      ssl: process.env.DB_SSL === 'require' ? { rejectUnauthorized: false } : false, // ✅ AGREGAR SSL
      entities: [__dirname + '/**/*.entity{.ts,.js}'],
      synchronize: false,
      migrations: ['src/migration/*.ts'],
      autoLoadEntities: true,
    }),
    UserModule,
    DoctorModule,
    AuthModule,
    NutritionModule,
    MedicalHistoryModule,
    CitasMedicasModule,
    PhysicalActivityModule,
    RecommendationModule,
    AlertsModule,
  ],
  controllers: [AppController],
})
export class AppModule { }

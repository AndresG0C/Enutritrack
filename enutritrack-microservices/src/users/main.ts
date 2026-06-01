import { NestFactory } from '@nestjs/core';
import { AppModule } from '../app.module';
import { ValidationPipe } from '@nestjs/common';
import cookieParser from 'cookie-parser';
import { xmlParser } from '../middleware/xml-parser.middleware';
import { XmlInterceptor } from '../interceptor/xml.interceptor';
import { DocumentBuilder, SwaggerModule } from '@nestjs/swagger';

async function bootstrap() {
  // Crear aplicación HTTP
  const app = await NestFactory.create(AppModule);
  app.use(cookieParser());

  app.use('/users', xmlParser);
  app.useGlobalInterceptors(new XmlInterceptor());
  app.useGlobalPipes(
    new ValidationPipe({
      whitelist: true,
      forbidNonWhitelisted: true,
      transform: true,
    }),
  );

  app.enableCors({
    origin: true,
    credentials: true,
  });
  const config = new DocumentBuilder()
    .setTitle('Microservicio de Paciente')
    .setDescription('API para Pacientes')
    .setVersion('1.1.0')
    .addServer(`http://localhost:3001`, 'Paciente')
    .addTag('Paciente', 'Endpoints de Paciente')
    .addBearerAuth()
    .build();

  const document = SwaggerModule.createDocument(app, config);
  SwaggerModule.setup('api/docs', app, document, {
    customSiteTitle: 'API Paciente - Documentación',
    swaggerOptions: {
      persistAuthorization: true,
      tryItOutEnabled: true,
    },
  });

  const port = process.env.PORT || 3001;
  await app.listen(port, '0.0.0.0');
  console.log('User Service running on port 3001 (HTTP) and 3101 (TCP)');
}
bootstrap();

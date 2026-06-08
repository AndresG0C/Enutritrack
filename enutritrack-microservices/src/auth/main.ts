// backend/api-gateway/src/main.ts
import { NestFactory } from '@nestjs/core';
import { AppModule } from '../app.module';
import { ValidationPipe } from '@nestjs/common';
import cookieParser from 'cookie-parser';
import { XmlInterceptor } from '../interceptor/xml.interceptor';
import { xmlParser } from '../middleware/xml-parser.middleware';
import { DocumentBuilder, SwaggerModule } from '@nestjs/swagger';

async function bootstrap() {
  const app = await NestFactory.create(AppModule);

  app.use(cookieParser());
  app.use('/auth', xmlParser);
  app.useGlobalInterceptors(new XmlInterceptor());
  app.enableCors({
    origin: true,
    credentials: true,
  });

  // Validación global
  app.useGlobalPipes(
    new ValidationPipe({
      whitelist: true,
      forbidNonWhitelisted: true,
      transform: true,
    }),
  );

  const config = new DocumentBuilder()
    .setTitle('Microservicio de Autenticación')
    .setDescription('API para autenticación de usuarios y doctores')
    .setVersion('1.1.0')
    .addServer(`http://localhost:3004`, 'Autenticación')
    .addTag('Authentication', 'Endpoints de autenticación')
    .addBearerAuth()
    .build();

  const document = SwaggerModule.createDocument(app, config);
  SwaggerModule.setup('api/docs', app, document, {
    customSiteTitle: 'API Autenticación - Documentación',
    swaggerOptions: {
      persistAuthorization: true,
      tryItOutEnabled: true,
    },
  });

  const port = process.env.PORT || 3004;
  await app.listen(port, '0.0.0.0');
  console.log(
    'Authenticated Service running on port 3004 (HTTP) and 3104 (TCP)',
  );
}
bootstrap();

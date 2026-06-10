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
  app.use('/recommendations', xmlParser);
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
    .setTitle('Microservicio de Recomendaciones')
    .setDescription('API para Recomendaciones')
    .setVersion('1.1.0')
    .addServer(`http://localhost:3006`, 'Recomendaciones')
    .addTag('Recomendaciones', 'Endpoints de Recomendaciones')
    .addBearerAuth()
    .build();

  const document = SwaggerModule.createDocument(app, config);
  SwaggerModule.setup('api/docs', app, document, {
    customSiteTitle: 'API Recomendaciones - Documentación',
    swaggerOptions: {
      persistAuthorization: true,
      tryItOutEnabled: true,
    },
  });

  const port = process.env.PORT || 3006;
  await app.listen(port, '0.0.0.0');
  console.log('User Service running on port 3006 (HTTP) and 3106 (TCP)');
}
bootstrap();

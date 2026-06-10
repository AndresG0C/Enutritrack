import { NestFactory } from '@nestjs/core';
import { AppModule } from '../app.module';
import { ValidationPipe } from '@nestjs/common';
import cookieParser from 'cookie-parser';
import { XmlInterceptor } from '../interceptor/xml.interceptor';
import { xmlParser } from '../middleware/xml-parser.middleware';
import { DocumentBuilder, SwaggerModule } from '@nestjs/swagger';

async function bootstrap() {
  // Crear aplicación HTTP
  const app = await NestFactory.create(AppModule);
  app.use(cookieParser());
  app.use('/alertas', xmlParser);
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
    .setTitle('Microservicio de Alertas')
    .setDescription('API para Alertas')
    .setVersion('1.1.0')
    .addServer(`http://localhost:3009`, 'Alertas')
    .addTag('Alertas', 'Endpoints de autenticación')
    .addBearerAuth()
    .build();

  const document = SwaggerModule.createDocument(app, config);
  SwaggerModule.setup('api/docs', app, document, {
    customSiteTitle: 'API Alertas - Documentación',
    swaggerOptions: {
      persistAuthorization: true,
      tryItOutEnabled: true,
    },
  });

  const port = process.env.PORT || 3009;
  await app.listen(port, '0.0.0.0');
  console.log('Alertas Service running on port 3009 (HTTP) and 3109 (TCP)');
}
bootstrap();

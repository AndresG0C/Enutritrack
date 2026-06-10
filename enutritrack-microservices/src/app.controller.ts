// src/app.controller.ts
import { Controller, Get, HttpCode } from '@nestjs/common';

@Controller('health/check')
export class AppController {
    @Get()
    @HttpCode(200)
    checkHealth() {
        return {
            status: 'ok',
            service: 'api-gateway',
            timestamp: new Date().toISOString(),
        };
    }
}
// src/app.controller.ts
import { Controller, Get, HttpCode } from '@nestjs/common';

@Controller('health/health')
export class AppController {
    @Get()
    @HttpCode(200)
    checkHealth() {
        return {
            status: 'ok',
            service: 'main-server',
            timestamp: new Date().toISOString(),
        };
    }
}
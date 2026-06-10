import {
  Controller,
  Get,
  Post,
  Body,
  Patch,
  Param,
  Delete,
  UseGuards,
  Query,
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
import { NutritionService } from './nutrition.service';
import { CreateFoodRecordDto } from './dto/create-food-record.dto';
import { UpdateFoodRecordDto } from './dto/update-food-record.dto';
import { AddFoodItemDto } from './dto/add-food-item.dto';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { CreateFoodDto } from './dto/create-food.dto';
import { UpdateFoodDto } from './dto/update-food.dto';
import { FoodsService } from './alimentos.service';

@ApiTags('Nutrition')
@ApiBearerAuth()
@Controller('nutrition')

export class NutritionController {
  constructor(
    private readonly nutritionService: NutritionService,
    private readonly foodsService: FoodsService,
  ) { }

  @Post('records')
  @UseGuards(JwtAuthGuard)
  @ApiOperation({
    summary: 'Crear registro de comida',
    description: 'Crea un nuevo registro de comida para un usuario',
  })
  @ApiBody({
    type: CreateFoodRecordDto,
    examples: {
      json: {
        summary: 'Ejemplo JSON - Desayuno',
        value: {
          usuarioId: '123e4567-e89b-12d3-a456-426614174000',
          tipo_comida: 'desayuno',
          fecha: '2024-01-15T08:00:00.000Z',
          notas: 'Desayuno completo con frutas',
        },
      },
      xml: {
        summary: 'Ejemplo XML - Almuerzo',
        value: `<?xml version="1.0" encoding="UTF-8"?>
<CreateFoodRecordDto>
  <usuarioId>123e4567-e89b-12d3-a456-426614174000</usuarioId>
  <tipo_comida>almuerzo</tipo_comida>
  <fecha>2024-01-15T13:30:00.000Z</fecha>
  <notas>Almuerzo balanceado</notas>
</CreateFoodRecordDto>`,
      },
    },
  })
  @ApiResponse({
    status: 201,
    description: 'Registro de comida creado exitosamente',
    schema: {
      example: {
        id: '223e4567-e89b-12d3-a456-426614174000',
        fecha: '2024-01-15T08:00:00.000Z',
        tipo_comida: 'desayuno',
        notas: 'Desayuno completo con frutas',
        usuario: {
          id: '123e4567-e89b-12d3-a456-426614174000',
        },
      },
    },
  })
  @ApiResponse({
    status: 404,
    description: 'Usuario no encontrado',
  })
  createFoodRecord(@Body() createFoodRecordDto: CreateFoodRecordDto) {
    return this.nutritionService.createFoodRecord(createFoodRecordDto);
  }

  @Post('records/:recordId/items')
  @UseGuards(JwtAuthGuard)
  @ApiOperation({
    summary: 'Agregar alimento a registro',
    description:
      'Agrega un alimento específico a un registro de comida existente',
  })
  @ApiParam({
    name: 'recordId',
    type: String,
    description: 'ID del registro de comida',
    example: '223e4567-e89b-12d3-a456-426614174000',
  })
  @ApiBody({
    type: AddFoodItemDto,
    examples: {
      json: {
        summary: 'Ejemplo JSON - Manzana',
        value: {
          alimentoId: '323e4567-e89b-12d3-a456-426614174000',
          cantidad_gramos: 150,
          notas: 'Manzana roja mediana',
        },
      },
      xml: {
        summary: 'Ejemplo XML - Pollo',
        value: `<?xml version="1.0" encoding="UTF-8"?>
<AddFoodItemDto>
  <alimentoId>423e4567-e89b-12d3-a456-426614174000</alimentoId>
  <cantidad_gramos>200</cantidad_gramos>
  <notas>Pechuga de pollo a la plancha</notas>
</AddFoodItemDto>`,
      },
    },
  })
  @ApiResponse({
    status: 201,
    description: 'Alimento agregado exitosamente al registro',
    schema: {
      example: {
        id: '523e4567-e89b-12d3-a456-426614174000',
        cantidad_gramos: 150,
        calorias: 78,
        proteinas_g: 0.3,
        carbohidratos_g: 20.7,
        grasas_g: 0.2,
        fibra_g: 3.3,
        notas: 'Manzana roja mediana',
        alimento: {
          id: '323e4567-e89b-12d3-a456-426614174000',
          nombre: 'Manzana',
          categoria: 'frutas',
        },
      },
    },
  })
  @ApiResponse({
    status: 404,
    description: 'Registro de comida o alimento no encontrado',
  })
  addFoodItem(
    @Param('recordId') recordId: string,
    @Body() addFoodItemDto: AddFoodItemDto,
  ) {
    return this.nutritionService.addFoodItemToRecord(recordId, addFoodItemDto);
  }

  @Get('records/user/:userId')
  @UseGuards(JwtAuthGuard)
  @ApiOperation({
    summary: 'Obtener registros por usuario',
    description:
      'Retorna todos los registros de comida de un usuario específico',
  })
  @ApiParam({
    name: 'userId',
    type: String,
    description: 'ID del usuario',
    example: '123e4567-e89b-12d3-a456-426614174000',
  })
  @ApiResponse({
    status: 200,
    description: 'Lista de registros de comida obtenida exitosamente',
    schema: {
      example: [
        {
          id: '223e4567-e89b-12d3-a456-426614174000',
          fecha: '2024-01-15T08:00:00.000Z',
          tipo_comida: 'desayuno',
          notas: 'Desayuno completo',
          items: [
            {
              id: '523e4567-e89b-12d3-a456-426614174000',
              cantidad_gramos: 150,
              calorias: 78,
              proteinas_g: 0.3,
              carbohidratos_g: 20.7,
              grasas_g: 0.2,
              alimento: {
                id: '323e4567-e89b-12d3-a456-426614174000',
                nombre: 'Manzana',
                categoria: 'frutas',
              },
            },
          ],
        },
      ],
    },
  })
  findAllByUser(@Param('userId') userId: string) {
    return this.nutritionService.findAllByUser(userId);
  }

  @Get('records/:id')
  @UseGuards(JwtAuthGuard)
  @ApiOperation({
    summary: 'Obtener registro específico',
    description: 'Retorna un registro de comida específico con todos sus items',
  })
  @ApiParam({
    name: 'id',
    type: String,
    description: 'ID del registro de comida',
    example: '223e4567-e89b-12d3-a456-426614174000',
  })
  @ApiResponse({
    status: 200,
    description: 'Registro de comida encontrado',
    schema: {
      example: {
        id: '223e4567-e89b-12d3-a456-426614174000',
        fecha: '2024-01-15T08:00:00.000Z',
        tipo_comida: 'desayuno',
        notas: 'Desayuno completo con frutas',
        usuario: {
          id: '123e4567-e89b-12d3-a456-426614174000',
          nombre: 'Juan Pérez',
        },
        items: [
          {
            id: '523e4567-e89b-12d3-a456-426614174000',
            cantidad_gramos: 150,
            calorias: 78,
            proteinas_g: 0.3,
            carbohidratos_g: 20.7,
            grasas_g: 0.2,
            fibra_g: 3.3,
            alimento: {
              id: '323e4567-e89b-12d3-a456-426614174000',
              nombre: 'Manzana',
              categoria: 'frutas',
              calorias_por_100g: 52,
              proteinas_g_por_100g: 0.3,
              carbohidratos_g_por_100g: 13.8,
              grasas_g_por_100g: 0.2,
              fibra_g_por_100g: 2.4,
            },
          },
        ],
      },
    },
  })
  @ApiResponse({
    status: 404,
    description: 'Registro de comida no encontrado',
  })
  findOne(@Param('id') id: string) {
    return this.nutritionService.findOne(id);
  }

  @Get('daily-summary/:userId')
  @UseGuards(JwtAuthGuard)
  @ApiOperation({
    summary: 'Resumen nutricional diario',
    description:
      'Obtiene un resumen de todos los nutrientes consumidos por un usuario en una fecha específica',
  })
  @ApiParam({
    name: 'userId',
    type: String,
    description: 'ID del usuario',
    example: '123e4567-e89b-12d3-a456-426614174000',
  })
  @ApiQuery({
    name: 'date',
    type: String,
    required: false,
    description: 'Fecha en formato ISO (por defecto: fecha actual)',
    example: '2024-01-15',
  })
  @ApiResponse({
    status: 200,
    description: 'Resumen diario obtenido exitosamente',
    schema: {
      example: {
        total_calorias: 1850.5,
        total_proteinas: 75.2,
        total_carbohidratos: 210.3,
        total_grasas: 65.8,
        total_fibra: 25.4,
        comidas_por_tipo: {
          desayuno: 1,
          almuerzo: 1,
          cena: 1,
        },
        total_comidas: 3,
      },
    },
  })
  getDailySummary(
    @Param('userId') userId: string,
    @Query('date') date: string,
  ) {
    const targetDate = date ? new Date(date) : new Date();
    return this.nutritionService.getDailySummary(userId, targetDate);
  }

  @Get('foods/search')
  @UseGuards(JwtAuthGuard)
  @ApiOperation({
    summary: 'Buscar alimentos',
    description: 'Busca alimentos por nombre o categoría',
  })
  @ApiQuery({
    name: 'q',
    type: String,
    description: 'Término de búsqueda',
    example: 'manzana',
  })
  @ApiResponse({
    status: 200,
    description: 'Resultados de búsqueda obtenidos exitosamente',
    schema: {
      example: [
        {
          id: '323e4567-e89b-12d3-a456-426614174000',
          nombre: 'Manzana',
          categoria: 'frutas',
          calorias_por_100g: 52,
          proteinas_g_por_100g: 0.3,
          carbohidratos_g_por_100g: 13.8,
          grasas_g_por_100g: 0.2,
          fibra_g_por_100g: 2.4,
        },
        {
          id: '623e4567-e89b-12d3-a456-426614174000',
          nombre: 'Manzana Verde',
          categoria: 'frutas',
          calorias_por_100g: 58,
          proteinas_g_por_100g: 0.4,
          carbohidratos_g_por_100g: 14.1,
          grasas_g_por_100g: 0.1,
          fibra_g_por_100g: 2.8,
        },
      ],
    },
  })
  searchFoods(@Query('q') query: string) {
    return this.nutritionService.searchFoods(query);
  }

  @Get('foods/category/:category')
  @UseGuards(JwtAuthGuard)
  @ApiOperation({
    summary: 'Obtener alimentos por categoría',
    description: 'Retorna alimentos filtrados por categoría específica',
  })
  @ApiParam({
    name: 'category',
    type: String,
    description: 'Categoría de alimentos',
    example: 'frutas',
  })
  @ApiResponse({
    status: 200,
    description: 'Lista de alimentos por categoría obtenida exitosamente',
  })
  getFoodsByCategory(@Param('category') category: string) {
    return this.nutritionService.getFoodsByCategory(category);
  }

  @Patch('records/:id')
  @UseGuards(JwtAuthGuard)
  @ApiOperation({
    summary: 'Actualizar registro de comida',
    description: 'Actualiza la información de un registro de comida existente',
  })
  @ApiParam({
    name: 'id',
    type: String,
    description: 'ID del registro de comida',
    example: '223e4567-e89b-12d3-a456-426614174000',
  })
  @ApiBody({ type: UpdateFoodRecordDto })
  @ApiResponse({
    status: 200,
    description: 'Registro de comida actualizado exitosamente',
  })
  @ApiResponse({
    status: 404,
    description: 'Registro de comida no encontrado',
  })
  updateFoodRecord(
    @Param('id') id: string,
    @Body() updateFoodRecordDto: UpdateFoodRecordDto,
  ) {
    return this.nutritionService.updateFoodRecord(id, updateFoodRecordDto);
  }

  @Delete('records/items/:itemId')
  @UseGuards(JwtAuthGuard)
  @ApiOperation({
    summary: 'Eliminar item de comida',
    description: 'Elimina un alimento específico de un registro de comida',
  })
  @ApiParam({
    name: 'itemId',
    type: String,
    description: 'ID del item de comida a eliminar',
    example: '523e4567-e89b-12d3-a456-426614174000',
  })
  @ApiResponse({
    status: 200,
    description: 'Item eliminado exitosamente',
  })
  @ApiResponse({
    status: 404,
    description: 'Item no encontrado',
  })
  removeFoodItem(@Param('itemId') itemId: string) {
    return this.nutritionService.removeFoodItem(itemId);
  }

  @Delete('records/:id')
  @UseGuards(JwtAuthGuard)
  @ApiOperation({
    summary: 'Eliminar registro de comida',
    description: 'Elimina un registro de comida completo y todos sus items',
  })
  @ApiParam({
    name: 'id',
    type: String,
    description: 'ID del registro de comida a eliminar',
    example: '223e4567-e89b-12d3-a456-426614174000',
  })
  @ApiResponse({
    status: 200,
    description: 'Registro de comida eliminado exitosamente',
  })
  @ApiResponse({
    status: 404,
    description: 'Registro de comida no encontrado',
  })
  removeFoodRecord(@Param('id') id: string) {
    return this.nutritionService.removeFoodRecord(id);
  }

  @Get('foods/categories')
  @UseGuards(JwtAuthGuard)
  @ApiOperation({
    summary: 'Obtener categorías de alimentos',
    description:
      'Retorna la lista de todas las categorías de alimentos disponibles',
  })
  @ApiResponse({
    status: 200,
    description: 'Lista de categorías obtenida exitosamente',
    schema: {
      example: [
        'frutas',
        'verduras',
        'carnes',
        'lácteos',
        'cereales',
        'legumbres',
      ],
    },
  })
  getFoodCategories() {
    return this.nutritionService.getFoodCategories();
  }

  @Get('foods')
  @UseGuards(JwtAuthGuard)
  @ApiOperation({
    summary: 'Obtener todos los alimentos',
    description:
      'Retorna la lista completa de alimentos disponibles en el sistema',
  })
  @ApiResponse({
    status: 200,
    description: 'Lista de alimentos obtenida exitosamente',
  })
  getAllFoods() {
    return this.nutritionService.getAllFoods();
  }

  @Post('foods')
  @UseGuards(JwtAuthGuard)
  @ApiOperation({
    summary: 'Crear nuevo alimento',
    description: 'Agrega un nuevo alimento a la base de datos del sistema',
  })
  @ApiBody({
    type: CreateFoodDto,
    examples: {
      json: {
        summary: 'Ejemplo JSON - Nuevo alimento',
        value: {
          nombre: 'Quinoa',
          categoria: 'cereales',
          calorias_por_100g: 120,
          proteinas_g_por_100g: 4.4,
          carbohidratos_g_por_100g: 21.3,
          grasas_g_por_100g: 1.9,
          fibra_g_por_100g: 2.8,
          descripcion: 'Cereal andino rico en proteínas',
        },
      },
      xml: {
        summary: 'Ejemplo XML - Nuevo alimento',
        value: `<?xml version="1.0" encoding="UTF-8"?>
<CreateFoodDto>
  <nombre>Aguacate</nombre>
  <categoria>frutas</categoria>
  <calorias_por_100g>160</calorias_por_100g>
  <proteinas_g_por_100g>2.0</proteinas_g_por_100g>
  <carbohidratos_g_por_100g>8.5</carbohidratos_g_por_100g>
  <grasas_g_por_100g>14.7</grasas_g_por_100g>
  <fibra_g_por_100g>6.7</fibra_g_por_100g>
  <descripcion>Fruta rica en grasas saludables</descripcion>
</CreateFoodDto>`,
      },
    },
  })
  @ApiResponse({
    status: 201,
    description: 'Alimento creado exitosamente',
  })
  createFood(@Body() createFoodDto: CreateFoodDto) {
    return this.nutritionService.createFood(createFoodDto);
  }

  @Get('foods/:id')
  @UseGuards(JwtAuthGuard)
  @ApiOperation({
    summary: 'Obtener alimento específico',
    description: 'Retorna la información detallada de un alimento específico',
  })
  @ApiParam({
    name: 'id',
    type: String,
    description: 'ID del alimento',
    example: '323e4567-e89b-12d3-a456-426614174000',
  })
  @ApiResponse({
    status: 200,
    description: 'Alimento encontrado',
  })
  @ApiResponse({
    status: 404,
    description: 'Alimento no encontrado',
  })
  getFood(@Param('id') id: string) {
    return this.foodsService.findOne(id);
  }

  @Patch('foods/:id')
  @UseGuards(JwtAuthGuard)
  @ApiOperation({
    summary: 'Actualizar alimento',
    description: 'Actualiza la información de un alimento existente',
  })
  @ApiParam({
    name: 'id',
    type: String,
    description: 'ID del alimento a actualizar',
    example: '323e4567-e89b-12d3-a456-426614174000',
  })
  @ApiBody({ type: UpdateFoodDto })
  @ApiResponse({
    status: 200,
    description: 'Alimento actualizado exitosamente',
  })
  @ApiResponse({
    status: 404,
    description: 'Alimento no encontrado',
  })
  updateFood(@Param('id') id: string, @Body() updateFoodDto: UpdateFoodDto) {
    return this.foodsService.update(id, updateFoodDto);
  }

  @Delete('foods/:id')
  @UseGuards(JwtAuthGuard)
  @ApiOperation({
    summary: 'Eliminar alimento',
    description: 'Elimina un alimento de la base de datos del sistema',
  })
  @ApiParam({
    name: 'id',
    type: String,
    description: 'ID del alimento a eliminar',
    example: '323e4567-e89b-12d3-a456-426614174000',
  })
  @ApiResponse({
    status: 200,
    description: 'Alimento eliminado exitosamente',
  })
  @ApiResponse({
    status: 404,
    description: 'Alimento no encontrado',
  })
  removeFood(@Param('id') id: string) {
    return this.foodsService.remove(id);
  }

  @Get('health/check')
  @HttpCode(200)
  @ApiOperation({
    summary: 'Health Check',
    description: 'Verifica el estado del microservicio de nutrición',
  })
  @ApiResponse({
    status: 200,
    description: 'Microservicio funcionando correctamente',
    schema: {
      example: {
        status: 'online',
        timestamp: '2024-01-15T10:30:00.000Z',
        uptime: 3600,
        service: 'Microservicio de nutrición',
        version: '1.1.0',
      },
    },
  })
  healthCheck() {
    return this.nutritionService.healthCheck();
  }
}

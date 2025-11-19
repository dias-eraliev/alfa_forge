import { Controller, Get, Res } from '@nestjs/common';
import type { Response } from 'express';
import { join } from 'path';

@Controller('static')
export class StaticController {
    @Get('privacy-policy')
    getPrivacyPolicy(@Res() res: Response) {
        const filePath = join(process.cwd(), 'public', 'privacy-policy.html');
        return res.sendFile(filePath);
    }
}

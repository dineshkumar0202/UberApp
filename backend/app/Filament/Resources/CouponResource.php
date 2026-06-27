<?php

namespace App\Filament\Resources;

use App\Models\Coupon;
use Filament\Forms;
use Filament\Schemas\Schema;
use Filament\Resources\Resource;
use Filament\Tables;
use Filament\Tables\Table;
use App\Filament\Resources\CouponResource\Pages;

class CouponResource extends Resource
{
    protected static ?string $model = Coupon::class;

    protected static string|\BackedEnum|null $navigationIcon = 'heroicon-o-ticket';

    public static function form(\Filament\Schemas\Schema $form): \Filament\Schemas\Schema
    {
        return $form
            ->schema([
                Forms\Components\TextInput::make('code')
                    ->required()
                    ->unique(ignoreRecord: true)
                    ->maxLength(255),
                Forms\Components\Select::make('type')
                    ->options([
                        'percentage' => 'Percentage Discount',
                        'fixed' => 'Fixed Amount Discount',
                    ])
                    ->required(),
                Forms\Components\TextInput::make('value')
                    ->numeric()
                    ->required(),
                Forms\Components\DateTimePicker::make('expires_at')
                    ->required(),
                Forms\Components\TextInput::make('usage_limit')
                    ->numeric()
                    ->default(100),
            ]);
    }

    public static function table(Table $table): Table
    {
        return $table
            ->columns([
                Tables\Columns\TextColumn::make('code')
                    ->searchable()
                    ->sortable(),
                Tables\Columns\TextColumn::make('type')
                    ->badge(),
                Tables\Columns\TextColumn::make('value')
                    ->numeric()
                    ->sortable(),
                Tables\Columns\TextColumn::make('usage_limit')
                    ->numeric(),
                Tables\Columns\TextColumn::make('times_used')
                    ->numeric(),
                Tables\Columns\TextColumn::make('expires_at')
                    ->dateTime()
                    ->sortable(),
            ])
            ->filters([
                Tables\Filters\SelectFilter::make('type')
                    ->options([
                        'percentage' => 'Percentage',
                        'fixed' => 'Fixed Amount',
                    ]),
            ])
            ->actions([
                \Filament\Actions\EditAction::make(),
                \Filament\Actions\DeleteAction::make(),
            ])
            ->bulkActions([
                \Filament\Actions\BulkActionGroup::make([
                    \Filament\Actions\DeleteBulkAction::make(),
                ]),
            ]);
    }

    public static function getRelations(): array
    {
        return [];
    }

    public static function getPages(): array
    {
        return [
            'index' => Pages\ListCoupons::route('/'),
            'create' => Pages\CreateCoupon::route('/create'),
            'edit' => Pages\EditCoupon::route('/{record}/edit'),
        ];
    }
}

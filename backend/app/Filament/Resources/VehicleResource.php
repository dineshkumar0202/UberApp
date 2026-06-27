<?php

namespace App\Filament\Resources;

use App\Models\Vehicle;
use App\Models\Driver;
use Filament\Forms;
use Filament\Schemas\Schema;
use Filament\Resources\Resource;
use Filament\Tables;
use Filament\Tables\Table;
use App\Filament\Resources\VehicleResource\Pages;

class VehicleResource extends Resource
{
    protected static ?string $model = Vehicle::class;

    protected static string|\BackedEnum|null $navigationIcon = 'heroicon-o-truck';

    public static function form(\Filament\Schemas\Schema $form): \Filament\Schemas\Schema
    {
        return $form
            ->schema([
                Forms\Components\Select::make('driver_id')
                    ->relationship('driver', 'id')
                    ->getOptionLabelFromRecordUsing(fn ($record) => "Driver #{$record->id} - " . ($record->user?->name ?? 'Unnamed'))
                    ->required(),
                Forms\Components\Select::make('vehicle_type')
                    ->options([
                        'economy' => 'Economy',
                        'comfort' => 'Comfort',
                        'premium' => 'Premium',
                        'xl' => 'Ridoo XL',
                    ])
                    ->required(),
                Forms\Components\TextInput::make('make')
                    ->required()
                    ->maxLength(255),
                Forms\Components\TextInput::make('model')
                    ->required()
                    ->maxLength(255),
                Forms\Components\TextInput::make('plate_number')
                    ->required()
                    ->maxLength(255),
                Forms\Components\TextInput::make('color')
                    ->required()
                    ->maxLength(255),
            ]);
    }

    public static function table(Table $table): Table
    {
        return $table
            ->columns([
                Tables\Columns\TextColumn::make('driver.user.name')
                    ->label('Driver')
                    ->searchable()
                    ->sortable(),
                Tables\Columns\TextColumn::make('vehicle_type')
                    ->badge()
                    ->color(fn (string $state): string => match ($state) {
                        'premium' => 'success',
                        'comfort' => 'info',
                        'xl' => 'warning',
                        default => 'gray',
                    }),
                Tables\Columns\TextColumn::make('make')
                    ->searchable(),
                Tables\Columns\TextColumn::make('model')
                    ->searchable(),
                Tables\Columns\TextColumn::make('plate_number')
                    ->searchable(),
                Tables\Columns\TextColumn::make('color')
                    ->searchable(),
            ])
            ->filters([
                Tables\Filters\SelectFilter::make('vehicle_type')
                    ->options([
                        'economy' => 'Economy',
                        'comfort' => 'Comfort',
                        'premium' => 'Premium',
                        'xl' => 'Ridoo XL',
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
            'index' => Pages\ListVehicles::route('/'),
            'create' => Pages\CreateVehicle::route('/create'),
            'edit' => Pages\EditVehicle::route('/{record}/edit'),
        ];
    }
}

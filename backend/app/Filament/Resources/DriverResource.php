<?php

namespace App\Filament\Resources;

use App\Filament\Resources\DriverResource\Pages;
use App\Models\Driver;
use Filament\Forms;
use Filament\Schemas\Schema;
use Filament\Resources\Resource;
use Filament\Tables;
use Filament\Tables\Table;

class DriverResource extends Resource
{
    protected static ?string $model = Driver::class;

    protected static string|\BackedEnum|null $navigationIcon = 'heroicon-o-truck';

    public static function form(Schema $form): Schema
    {
        return $form
            ->schema([
                Forms\Components\Select::make('user_id')
                    ->relationship('user', 'name', fn ($query) => $query->where('role', 'driver'))
                    ->required()
                    ->searchable()
                    ->label('Driver User'),
                Forms\Components\TextInput::make('license_number')
                    ->maxLength(255),
                Forms\Components\DatePicker::make('license_expiry'),
                Forms\Components\Toggle::make('is_approved')
                    ->required(),
                Forms\Components\Toggle::make('is_online')
                    ->required()
                    ->disabled(),
                Forms\Components\TextInput::make('rating')
                    ->numeric()
                    ->default(5.00)
                    ->disabled(),

                \Filament\Schemas\Components\Section::make('Vehicle Information')
                    ->relationship('vehicle')
                    ->schema([
                        Forms\Components\TextInput::make('make')
                            ->required()
                            ->maxLength(255),
                        Forms\Components\TextInput::make('model')
                            ->required()
                            ->maxLength(255),
                        Forms\Components\TextInput::make('year')
                            ->numeric()
                            ->required(),
                        Forms\Components\TextInput::make('color')
                            ->required()
                            ->maxLength(255),
                        Forms\Components\TextInput::make('plate_number')
                            ->required()
                            ->unique(ignoreRecord: true)
                            ->maxLength(255),
                        Forms\Components\Select::make('vehicle_type')
                            ->options([
                                'economy' => 'Ridoo Go (Economy)',
                                'premier' => 'Ridoo Premier',
                                'xl' => 'Ridoo XL',
                            ])
                            ->required(),
                        Forms\Components\Toggle::make('is_active')
                            ->default(true)
                            ->required(),
                    ])
                    ->columns(2),
            ]);
    }

    public static function table(Table $table): Table
    {
        return $table
            ->columns([
                Tables\Columns\TextColumn::make('user.name')
                    ->label('Driver Name')
                    ->searchable()
                    ->sortable(),
                Tables\Columns\TextColumn::make('user.phone')
                    ->label('Phone')
                    ->searchable(),
                Tables\Columns\TextColumn::make('license_number')
                    ->searchable(),
                Tables\Columns\TextColumn::make('license_expiry')
                    ->date()
                    ->sortable(),
                Tables\Columns\IconColumn::make('is_approved')
                    ->boolean()
                    ->sortable(),
                Tables\Columns\IconColumn::make('is_online')
                    ->boolean()
                    ->sortable(),
                Tables\Columns\TextColumn::make('rating')
                    ->numeric()
                    ->sortable(),
                Tables\Columns\TextColumn::make('vehicle.plate_number')
                    ->label('Plate Number')
                    ->searchable(),
            ])
            ->filters([
                Tables\Filters\TernaryFilter::make('is_approved')
                    ->label('Approval Status'),
                Tables\Filters\TernaryFilter::make('is_online')
                    ->label('Online Status'),
            ])
            ->actions([
                \Filament\Actions\Action::make('approve')
                    ->action(fn (Driver $record) => $record->update(['is_approved' => true]))
                    ->requiresConfirmation()
                    ->color('success')
                    ->icon('heroicon-o-check-circle')
                    ->visible(fn (Driver $record): bool => ! $record->is_approved),
                \Filament\Actions\EditAction::make(),
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
            'index' => Pages\ListDrivers::route('/'),
            'create' => Pages\CreateDriver::route('/create'),
            'edit' => Pages\EditDriver::route('/{record}/edit'),
        ];
    }
}

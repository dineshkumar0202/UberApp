<?php

namespace App\Filament\Resources;

use App\Filament\Resources\RideResource\Pages;
use App\Models\Ride;
use Filament\Forms;
use Filament\Schemas\Schema;
use Filament\Resources\Resource;
use Filament\Tables;
use Filament\Tables\Table;

class RideResource extends Resource
{
    protected static ?string $model = Ride::class;

    protected static string|\BackedEnum|null $navigationIcon = 'heroicon-o-map';

    public static function form(Schema $form): Schema
    {
        return $form
            ->schema([
                Forms\Components\Select::make('customer_id')
                    ->relationship('customer', 'name')
                    ->disabled()
                    ->required(),
                Forms\Components\Select::make('driver_id')
                    ->relationship('driver.user', 'name')
                    ->disabled(),
                Forms\Components\TextInput::make('pickup_address')
                    ->required()
                    ->disabled(),
                Forms\Components\TextInput::make('drop_address')
                    ->required()
                    ->disabled(),
                Forms\Components\TextInput::make('ride_type')
                    ->required()
                    ->disabled(),
                Forms\Components\Select::make('status')
                    ->options([
                        'pending' => 'Pending',
                        'searching' => 'Searching',
                        'accepted' => 'Accepted',
                        'arrived' => 'Arrived',
                        'started' => 'Started',
                        'completed' => 'Completed',
                        'cancelled' => 'Cancelled',
                    ])
                    ->required(),
                Forms\Components\TextInput::make('total_fare')
                    ->numeric(),
                Forms\Components\TextInput::make('payment_method')
                    ->disabled(),
                Forms\Components\TextInput::make('payment_status')
                    ->disabled(),
                Forms\Components\DateTimePicker::make('started_at')
                    ->disabled(),
                Forms\Components\DateTimePicker::make('completed_at')
                    ->disabled(),
            ]);
    }

    public static function table(Table $table): Table
    {
        return $table
            ->columns([
                Tables\Columns\TextColumn::make('id')
                    ->sortable(),
                Tables\Columns\TextColumn::make('customer.name')
                    ->label('Customer')
                    ->searchable()
                    ->sortable(),
                Tables\Columns\TextColumn::make('driver.user.name')
                    ->label('Driver')
                    ->searchable()
                    ->sortable(),
                Tables\Columns\TextColumn::make('pickup_address')
                    ->searchable()
                    ->limit(20),
                Tables\Columns\TextColumn::make('drop_address')
                    ->searchable()
                    ->limit(20),
                Tables\Columns\TextColumn::make('ride_type')
                    ->searchable(),
                Tables\Columns\TextColumn::make('status')
                    ->badge()
                    ->color(fn (string $state): string => match ($state) {
                        'completed' => 'success',
                        'searching' => 'info',
                        'cancelled' => 'danger',
                        'accepted', 'arrived', 'started' => 'warning',
                        default => 'gray',
                    }),
                Tables\Columns\TextColumn::make('total_fare')
                    ->label('Fare')
                    ->money('INR')
                    ->sortable(),
                Tables\Columns\TextColumn::make('payment_status')
                    ->badge()
                    ->color(fn (string $state): string => match ($state) {
                        'completed' => 'success',
                        'pending' => 'warning',
                        default => 'gray',
                    }),
                Tables\Columns\TextColumn::make('created_at')
                    ->dateTime()
                    ->sortable(),
            ])
            ->filters([
                Tables\Filters\SelectFilter::make('status')
                    ->options([
                        'searching' => 'Searching',
                        'accepted' => 'Accepted',
                        'arrived' => 'Arrived',
                        'started' => 'Started',
                        'completed' => 'Completed',
                        'cancelled' => 'Cancelled',
                    ]),
            ])
            ->actions([
                \Filament\Actions\EditAction::make(),
            ])
            ->bulkActions([]);
    }

    public static function getRelations(): array
    {
        return [];
    }

    public static function getPages(): array
    {
        return [
            'index' => Pages\ListRides::route('/'),
            'edit' => Pages\EditRide::route('/{record}/edit'),
        ];
    }
}

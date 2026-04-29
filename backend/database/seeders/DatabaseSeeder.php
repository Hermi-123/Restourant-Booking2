<?php

namespace Database\Seeders;

use App\Models\MenuItem;
use App\Models\Table;
use Illuminate\Database\Seeder;

class DatabaseSeeder extends Seeder
{
    public function run(): void
    {
        // Seed Tables
        for ($i = 1; $i <= 10; $i++) {
            Table::create([
                'table_number' => "T$i",
                'qr_code' => "QR_TABLE_$i"
            ]);
        }

        // Seed Menu Items (Humanized Terminology)
        $menuItems = [
            // Bite-sized Joy (Appetizers)
            ['name' => 'Crispy Clouds', 'category' => 'Bite-sized Joy', 'price' => 8.50, 'prep_time' => 10],
            ['name' => 'Garden Whispers', 'category' => 'Bite-sized Joy', 'price' => 7.00, 'prep_time' => 8],
            ['name' => 'Spicy Spark', 'category' => 'Bite-sized Joy', 'price' => 9.25, 'prep_time' => 12],
            
            // The Main Event (Main Courses)
            ['name' => 'Umami Symphony', 'category' => 'The Main Event', 'price' => 24.00, 'prep_time' => 25],
            ['name' => 'Ocean Treasure', 'category' => 'The Main Event', 'price' => 28.50, 'prep_time' => 20],
            ['name' => 'Earthly Feast', 'category' => 'The Main Event', 'price' => 18.00, 'prep_time' => 15],
            
            // Sweet Endings (Desserts)
            ['name' => 'Cocoa Dream', 'category' => 'Sweet Endings', 'price' => 12.00, 'prep_time' => 10],
            ['name' => 'Velvet Touch', 'category' => 'Sweet Endings', 'price' => 10.50, 'prep_time' => 5],
            
            // Liquid Love (Drinks)
            ['name' => 'Morning Glow', 'category' => 'Liquid Love', 'price' => 5.50, 'prep_time' => 3],
            ['name' => 'Midnight Chill', 'category' => 'Liquid Love', 'price' => 6.00, 'prep_time' => 3],
            ['name' => 'Bubbly Joy', 'category' => 'Liquid Love', 'price' => 4.50, 'prep_time' => 2],
        ];

        foreach ($menuItems as $item) {
            MenuItem::create($item);
        }
    }
}

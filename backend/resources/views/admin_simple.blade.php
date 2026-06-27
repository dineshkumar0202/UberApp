<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Ridoo Simple Admin Panel</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <link href="https://fonts.googleapis.com/css2?family=Outfit:wght@300;400;600;700&display=swap" rel="stylesheet">
    <style>
        body {
            font-family: 'Outfit', sans-serif;
        }
    </style>
</head>
<body class="bg-slate-50 text-slate-800">

    <!-- Navbar -->
    <nav class="bg-black text-white px-8 py-4 flex justify-between items-center shadow-lg">
        <div class="flex items-center space-x-3">
            <div class="w-8 h-8 bg-amber-500 rounded-lg flex items-center justify-center font-bold text-black text-lg">R</div>
            <span class="text-xl font-bold tracking-tight">Ridoo Admin <span class="text-xs bg-amber-500 text-black px-2 py-0.5 rounded font-mono font-semibold ml-2">SIMPLE UI</span></span>
        </div>
        <div class="flex items-center space-x-6 text-sm text-slate-300">
            <span>Logged in as: <strong>admin@ridoo.com</strong></span>
            <a href="/admin" class="hover:text-amber-500 font-semibold transition">Filament Admin Panels &rarr;</a>
        </div>
    </nav>

    <!-- Main Container -->
    <main class="max-w-7xl mx-auto px-6 py-8">
        
        <!-- Alerts -->
        @if(session('success'))
            <div class="mb-6 p-4 bg-emerald-50 border border-emerald-200 text-emerald-800 rounded-xl flex items-center space-x-3">
                <svg class="w-5 h-5 text-emerald-500 flex-shrink-0" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z"></path></svg>
                <span class="font-medium">{{ session('success') }}</span>
            </div>
        @endif

        <!-- Stats Overview -->
        <div class="grid grid-cols-1 md:grid-cols-4 gap-6 mb-8">
            <div class="bg-white p-6 rounded-2xl shadow-sm border border-slate-100 flex items-center space-x-4">
                <div class="p-3 bg-amber-100 text-amber-600 rounded-xl">
                    <svg class="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 4.354a4 4 0 110 5.292M15 21H3v-1a6 6 0 0112 0v1zm0 0h6v-1a6 6 0 00-9-5.197M13 7a4 4 0 11-8 0 4 4 0 018 0z"></path></svg>
                </div>
                <div>
                    <div class="text-xs font-semibold text-slate-400 uppercase tracking-wider">Total Users</div>
                    <div class="text-2xl font-bold mt-1">{{ $users->count() }}</div>
                </div>
            </div>
            <div class="bg-white p-6 rounded-2xl shadow-sm border border-slate-100 flex items-center space-x-4">
                <div class="p-3 bg-blue-100 text-blue-600 rounded-xl">
                    <svg class="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M8 7h12m0 0l-4-4m4 4l-4 4m0 6H4m0 0l4 4m-4-4l4-4"></path></svg>
                </div>
                <div>
                    <div class="text-xs font-semibold text-slate-400 uppercase tracking-wider">Total Drivers</div>
                    <div class="text-2xl font-bold mt-1">{{ $drivers->count() }}</div>
                </div>
            </div>
            <div class="bg-white p-6 rounded-2xl shadow-sm border border-slate-100 flex items-center space-x-4">
                <div class="p-3 bg-purple-100 text-purple-600 rounded-xl">
                    <svg class="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 20l-5.447-2.724A1 1 0 013 16.382V5.618a1 1 0 011.447-.894L9 7m0 13l6-3m-6 3V7m6 10l4.553 2.276A1 1 0 0021 18.382V7.618a1 1 0 00-.553-.894L15 4m0 13V4m0 0L9 7"></path></svg>
                </div>
                <div>
                    <div class="text-xs font-semibold text-slate-400 uppercase tracking-wider">Rides Booked</div>
                    <div class="text-2xl font-bold mt-1">{{ $rides->count() }}</div>
                </div>
            </div>
            <div class="bg-white p-6 rounded-2xl shadow-sm border border-slate-100 flex items-center space-x-4">
                <div class="p-3 bg-emerald-100 text-emerald-600 rounded-xl">
                    <svg class="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12l2 2 4-4m5.618-4.016A11.955 11.955 0 0112 2.944a11.955 11.955 0 01-8.618 3.04A12.02 12.02 0 003 9c0 5.591 3.824 10.29 9 11.622 5.176-1.332 9-6.03 9-11.622 0-1.042-.133-2.052-.382-3.016z"></path></svg>
                </div>
                <div>
                    <div class="text-xs font-semibold text-slate-400 uppercase tracking-wider">Online Drivers</div>
                    <div class="text-2xl font-bold mt-1">{{ $drivers->where('is_online', true)->count() }}</div>
                </div>
            </div>
        </div>

        <!-- Layout Grid -->
        <div class="grid grid-cols-1 lg:grid-cols-3 gap-8">
            
            <!-- Drivers Approval Section (Left Column) -->
            <div class="lg:col-span-2 bg-white rounded-2xl shadow-sm border border-slate-100 overflow-hidden">
                <div class="px-6 py-5 border-b border-slate-100 flex justify-between items-center bg-slate-50/50">
                    <h2 class="text-lg font-bold text-slate-800 flex items-center space-x-2">
                        <span>Drivers & Vehicles Registry</span>
                    </h2>
                </div>
                <div class="overflow-x-auto">
                    <table class="w-full text-left border-collapse">
                        <thead>
                            <tr class="text-xs font-semibold uppercase text-slate-400 bg-slate-50 border-b border-slate-100">
                                <th class="px-6 py-4">Driver Info</th>
                                <th class="px-6 py-4">Vehicle Details</th>
                                <th class="px-6 py-4">Status</th>
                                <th class="px-6 py-4 text-right">Actions</th>
                            </tr>
                        </thead>
                        <tbody class="divide-y divide-slate-100">
                            @forelse($drivers as $driver)
                                <tr class="hover:bg-slate-50/50 transition">
                                    <td class="px-6 py-4">
                                        <div class="font-bold">{{ $driver->user->name ?? 'Unknown' }}</div>
                                        <div class="text-xs text-slate-400 mt-0.5">{{ $driver->user->phone ?? 'No Phone' }}</div>
                                        <div class="text-[10px] bg-slate-100 text-slate-600 px-1.5 py-0.5 rounded font-mono inline-block mt-1">Lic: {{ $driver->license_number }}</div>
                                    </td>
                                    <td class="px-6 py-4">
                                        @if($driver->vehicle)
                                            <div class="font-semibold text-sm">{{ $driver->vehicle->color }} {{ $driver->vehicle->make }} {{ $driver->vehicle->model }}</div>
                                            <div class="text-xs text-slate-400 font-mono mt-0.5">{{ $driver->vehicle->plate_number }} • {{ strtoupper($driver->vehicle->vehicle_type) }}</div>
                                        @else
                                            <span class="text-xs text-slate-400 italic">No vehicle profile</span>
                                        @endif
                                    </td>
                                    <td class="px-6 py-4">
                                        @if($driver->is_approved)
                                            <span class="inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-semibold bg-emerald-50 text-emerald-700 border border-emerald-100">
                                                Approved
                                            </span>
                                        @else
                                            <span class="inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-semibold bg-amber-50 text-amber-700 border border-amber-100">
                                                Pending Approval
                                            </span>
                                        @endif
                                        <div class="text-[10px] mt-1 text-slate-400">
                                            Online: <span class="{{ $driver->is_online ? 'text-emerald-500 font-bold' : 'text-slate-400' }}">{{ $driver->is_online ? 'YES' : 'NO' }}</span>
                                        </div>
                                    </td>
                                    <td class="px-6 py-4 text-right">
                                        @if(!$driver->is_approved)
                                            <form action="/admin-simple/driver/{{ $driver->id }}/approve" method="POST">
                                                @csrf
                                                <button type="submit" class="bg-black hover:bg-slate-800 text-white text-xs font-semibold px-4 py-2 rounded-xl transition shadow-sm">
                                                    Approve
                                                </button>
                                            </form>
                                        @else
                                            <span class="text-slate-400 text-xs flex justify-end items-center space-x-1 font-medium">
                                                <svg class="w-4 h-4 text-emerald-500" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M5 13l4 4L19 7"></path></svg>
                                                <span>Active</span>
                                            </span>
                                        @endif
                                    </td>
                                </tr>
                            @empty
                                <tr>
                                    <td colspan="4" class="px-6 py-8 text-center text-slate-400 italic text-sm">No drivers registered yet.</td>
                                </tr>
                            @endforelse
                        </tbody>
                    </table>
                </div>
            </div>

            <!-- Users Registry (Right Column) -->
            <div class="bg-white rounded-2xl shadow-sm border border-slate-100 overflow-hidden">
                <div class="px-6 py-5 border-b border-slate-100 bg-slate-50/50">
                    <h2 class="text-lg font-bold text-slate-800">Users & Roles</h2>
                </div>
                <ul class="divide-y divide-slate-100 max-h-[480px] overflow-y-auto">
                    @forelse($users as $user)
                        <li class="p-4 flex justify-between items-center hover:bg-slate-50/50 transition">
                            <div>
                                <div class="font-bold text-sm">{{ $user->name }}</div>
                                <div class="text-xs text-slate-400 font-mono mt-0.5">{{ $user->phone }}</div>
                                <div class="text-xs text-slate-500 mt-1 font-semibold">{{ $user->email }}</div>
                            </div>
                            <div>
                                <span class="inline-block px-2.5 py-1 text-[10px] font-bold uppercase tracking-wider rounded-lg
                                    @if($user->role === 'admin') bg-red-50 text-red-700 border border-red-100
                                    @elseif($user->role === 'driver') bg-amber-50 text-amber-700 border border-amber-100
                                    @else bg-emerald-50 text-emerald-700 border border-emerald-100
                                    @endif">
                                    {{ $user->role }}
                                </span>
                            </div>
                        </li>
                    @empty
                        <li class="p-6 text-center text-slate-400 italic text-sm">No users found.</li>
                    @endforelse
                </ul>
            </div>
        </div>

        <!-- Rides History (Full Width Bottom) -->
        <div class="bg-white rounded-2xl shadow-sm border border-slate-100 mt-8 overflow-hidden">
            <div class="px-6 py-5 border-b border-slate-100 bg-slate-50/50">
                <h2 class="text-lg font-bold text-slate-800">Rides History Monitoring</h2>
            </div>
            <div class="overflow-x-auto">
                <table class="w-full text-left border-collapse">
                    <thead>
                        <tr class="text-xs font-semibold uppercase text-slate-400 bg-slate-50 border-b border-slate-100">
                            <th class="px-6 py-4">Ride ID</th>
                            <th class="px-6 py-4">Customer</th>
                            <th class="px-6 py-4">Driver</th>
                            <th class="px-6 py-4">Route Details</th>
                            <th class="px-6 py-4">Fare & Payment</th>
                            <th class="px-6 py-4">Status</th>
                        </tr>
                    </thead>
                    <tbody class="divide-y divide-slate-100">
                        @forelse($rides as $ride)
                            <tr class="hover:bg-slate-50/50 transition">
                                <td class="px-6 py-4 font-mono font-bold text-sm">#{{ $ride->id }}</td>
                                <td class="px-6 py-4">
                                    <div class="font-semibold">{{ $ride->customer->name ?? 'Unknown' }}</div>
                                    <div class="text-xs text-slate-400 font-mono mt-0.5">{{ $ride->customer->phone ?? 'No Phone' }}</div>
                                </td>
                                <td class="px-6 py-4">
                                    @if($ride->driver)
                                        <div class="font-semibold">{{ $ride->driver->user->name ?? 'Unknown' }}</div>
                                        <div class="text-xs text-slate-400 font-mono mt-0.5">{{ $ride->driver->user->phone ?? 'No Phone' }}</div>
                                    @else
                                        <span class="text-xs text-slate-400 italic">Not Assigned</span>
                                    @endif
                                </td>
                                <td class="px-6 py-4">
                                    <div class="text-xs"><strong class="text-emerald-500">Pick:</strong> {{ $ride->pickup_address }}</div>
                                    <div class="text-xs mt-1"><strong class="text-rose-500">Drop:</strong> {{ $ride->drop_address }}</div>
                                </td>
                                <td class="px-6 py-4">
                                    <div class="font-bold text-slate-800">₹{{ $ride->total_fare ?? '0.00' }}</div>
                                    <div class="text-[10px] text-slate-400 uppercase mt-0.5 font-semibold">{{ $ride->payment_method }} • {{ $ride->payment_status }}</div>
                                </td>
                                <td class="px-6 py-4">
                                    <span class="inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-semibold
                                        @if($ride->status === 'completed') bg-emerald-50 text-emerald-700 border border-emerald-100
                                        @elseif($ride->status === 'searching') bg-blue-50 text-blue-700 border border-blue-100
                                        @elseif($ride->status === 'cancelled') bg-rose-50 text-rose-700 border border-rose-100
                                        @else bg-amber-50 text-amber-700 border border-amber-100
                                        @endif">
                                        {{ ucfirst($ride->status) }}
                                    </span>
                                </td>
                            </tr>
                        @empty
                            <tr>
                                <td colspan="6" class="px-6 py-8 text-center text-slate-400 italic text-sm">No rides created yet.</td>
                            </tr>
                        @endforelse
                    </tbody>
                </table>
            </div>
        </div>

    </main>

</body>
</html>

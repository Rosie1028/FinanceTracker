import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'screens/car_loan_screen.dart';
import 'screens/transactions_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Finance Tracker',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme(
          brightness: Brightness.light,
          primary: const Color(0xFF00916E), // Teal green as main color
          onPrimary: Colors.white, // White text on green
          secondary: const Color(0xFFFFCF00), // Yellow as secondary
          onSecondary: const Color(0xFF190B28), // Dark text on yellow
          tertiary: const Color(0xFF7D83FF), // Blue as tertiary
          onTertiary: Colors.white,
          error: Colors.red,
          onError: Colors.white,
          background: Colors.white,
          onBackground: const Color(0xFF190B28), // Main text color
          surface: Colors.white,
          onSurface: const Color(0xFF190B28), // Surface text color
          primaryContainer: const Color(0xFF00916E).withOpacity(0.1),
          onPrimaryContainer: const Color(0xFF00916E),
          secondaryContainer: const Color(0xFFFFCF00).withOpacity(0.1),
          onSecondaryContainer: const Color(0xFFFFCF00),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF00916E),
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: Color(0xFF00916E),
          foregroundColor: Colors.white,
        ),
        navigationBarTheme: NavigationBarThemeData(
          backgroundColor: Colors.white,
          indicatorColor: const Color(0xFF00916E).withOpacity(0.1),
          labelTextStyle: MaterialStateProperty.all(
            const TextStyle(
              color: Color(0xFF00916E),
              fontWeight: FontWeight.w500,
            ),
          ),
          iconTheme: MaterialStateProperty.all(
            const IconThemeData(
              color: Color(0xFF00916E),
            ),
          ),
        ),
      ),
      home: const MainScreen(),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const HomeScreen(),
    const CarLoanScreen(),
    const TransactionsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.account_balance),
            label: 'Loans',
          ),
          NavigationDestination(
            icon: Icon(Icons.receipt_long),
            label: 'Transactions',
          ),
        ],
      ),
    );
  }
}

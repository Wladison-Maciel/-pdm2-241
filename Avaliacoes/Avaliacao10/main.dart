import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Formulário com Validação',
      theme: ThemeData(
        scaffoldBackgroundColor: Colors.grey[200],
        textTheme: TextTheme(
          titleLarge: TextStyle(color: Colors.blueGrey[800]),
          bodyMedium: TextStyle(color: Colors.blueGrey[600]),
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.blue),
            borderRadius: BorderRadius.circular(8.0),
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.grey),
            borderRadius: BorderRadius.circular(8.0),
          ),
          labelStyle: TextStyle(color: Colors.blueGrey[600]),
          errorStyle: TextStyle(color: Colors.red),
        ),
        buttonTheme: ButtonThemeData(
          buttonColor: const Color.fromARGB(255, 10, 6, 123),
          textTheme: ButtonTextTheme.primary,
        ), colorScheme: ColorScheme.fromSwatch(primarySwatch: Colors.blue).copyWith(secondary: const Color.fromARGB(255, 15, 5, 101)),
      ),
      home: MyForm(),
    );
  }
}

class MyForm extends StatefulWidget {
  @override
  _MyFormState createState() => _MyFormState();
}

class _MyFormState extends State<MyForm> {
  final _formKey = GlobalKey<FormState>();
  final _dateController = TextEditingController();
  final _emailController = TextEditingController();
  final _cpfController = TextEditingController();
  final _valueController = TextEditingController();

  bool _isValidDate(String date) {
    final regex = RegExp(r'^\d{2}-\d{2}-\d{4}$');
    if (!regex.hasMatch(date)) return false;

    try {
      final parts = date.split('-');
      final day = int.parse(parts[0]);
      final month = int.parse(parts[1]);
      final year = int.parse(parts[2]);

      final dateTime = DateTime(year, month, day);
      return dateTime.day == day && dateTime.month == month && dateTime.year == year;
    } catch (e) {
      return false;
    }
  }

  bool _isValidEmail(String email) {
    final regex = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');
    return regex.hasMatch(email);
  }

  bool _isValidCPF(String cpf) {
    cpf = cpf.replaceAll(RegExp(r'[^\d]'), '');

    if (cpf.length != 11 || RegExp(r'^(\d)\1{10}$').hasMatch(cpf)) {
      return false;
    }

    int calculateDigit(List<int> digits, int multiplier) {
      int sum = 0;
      for (int i = 0; i < digits.length; i++) {
        sum += digits[i] * (multiplier - i);
      }
      int remainder = (sum * 10) % 11;
      return remainder == 10 || remainder == 11 ? 0 : remainder;
    }

    List<int> digits = cpf.split('').map(int.parse).toList();
    int firstDigit = calculateDigit(digits.sublist(0, 9), 10);
    int secondDigit = calculateDigit(digits.sublist(0, 10), 11);

    return firstDigit == digits[9] && secondDigit == digits[10];
  }

  bool _isValidValue(String value) {
    final regex = RegExp(r'^\d+(\,\d{2})?$');
    return regex.hasMatch(value);
  }

  void _validateForm() {
    if (_formKey.currentState?.validate() ?? false) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Formulário enviado com sucesso!')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Formulário com Validação - PDMII'),
        backgroundColor: const Color.fromARGB(255, 95, 171, 233),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
          child: Padding(
            padding: EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    'Preencha o formulário abaixo:',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.blueGrey[800]),
                  ),
                  SizedBox(height: 16.0),
                  _buildTextFormField(
                    controller: _dateController,
                    label: 'Data (dd-mm-aaaa)',
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor, insira uma data.';
                      }
                      if (!_isValidDate(value)) {
                        return 'Data inválida. Use o formato dd-mm-aaaa.';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 16.0),
                  _buildTextFormField(
                    controller: _emailController,
                    label: 'Email',
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor, insira um e-mail.';
                      }
                      if (!_isValidEmail(value)) {
                        return 'Email inválido.';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 16.0),
                  _buildTextFormField(
                    controller: _cpfController,
                    label: 'CPF (000.000.000-00)',
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor, insira um CPF.';
                      }
                      if (!_isValidCPF(value)) {
                        return 'CPF inválido.';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 16.0),
                  _buildTextFormField(
                    controller: _valueController,
                    label: 'Valor',
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor, insira um valor.';
                      }
                      if (!_isValidValue(value)) {
                        return 'Valor inválido. Use o formato 1234,56.';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _validateForm,
                    child: Text('Enviar'),
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white, backgroundColor: const Color.fromARGB(255, 7, 101, 118), // Text color
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      padding: EdgeInsets.symmetric(vertical: 12.0),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextFormField({
    required TextEditingController controller,
    required String label,
    required FormFieldValidator<String> validator,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.blueGrey[600]),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
      ),
      validator: validator,
    );
  }
}

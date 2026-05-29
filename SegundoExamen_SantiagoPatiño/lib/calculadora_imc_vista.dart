import 'package:flutter/material.dart';

class CalculadoraImcVista extends StatefulWidget {
  //Creamos la clase CalculadoraImcVista la cual hereda de StatefulWidget para poder crear widgets
  const CalculadoraImcVista({super.key}); //Definimos el constructor de la clase

  @override
  State<StatefulWidget> createState() => _CalculadoraState(); //Definimos la variable la cual nos va ah guardar loes estados (_CalculadoraState)
}

class _CalculadoraState extends State<CalculadoraImcVista> {
  //Por medio de esta clase vamos ah almacenar todos los datos que vamos ah construir
  //Controladores
  final _pesoControlador = TextEditingController(); //Controladores para el peso
  final _alturaControlador =TextEditingController(); //Controladores para la altura


  //Variable para guardar las validaciones
  final _formKey = GlobalKey<FormState>();


  //Variables para los resultados
  String _resultadoIMC = "";
  String _categoria = "";

  void _CalcularIMC() {
    if (!_formKey.currentState!.validate()){
      return;

    }
    

    double peso = double.parse(_pesoControlador.text);
    double altura = double.parse(_alturaControlador.text);

    //Hacemos el calculo con la respectiva formula
    double imc = peso / (altura * altura);

    //Variable para revisar la categoria//
    String categoria;

    //Logica para determinar la categoria
    if (imc < 18.5) {
      categoria = "Bajo peso";
    } else if (imc >= 18.5 && imc < 25) {
      categoria = "Peso normal";
    } else if (imc >= 25 && imc < 30) {
      categoria = "Sobrepeso";
    } else {
      categoria = "Obesidad";
    }

    //Actualizamos la UI (indicando el IMC)
    setState(() {
      _resultadoIMC =
          "Tu IMC es: ${imc.toStringAsFixed(2)}"; //Ponemos en pantalla el valor del IMC con los primeros dos valores despues del decimal
      _categoria = "Categoria: ${categoria}"; //Ponemos en pantalla la categoria
    });
  }

  //Creacion de la interfaz
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        //Construimos el AppBar requerido
        title: const Text(
          "Calculadora de IMC",
          style: TextStyle(fontWeight: FontWeight.bold),
        ), //Definimos el titulo de nuestro AppBar
        centerTitle: true, //Centramos el titulo
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: theme.colorScheme.onSurface,
      ),
      body: SingleChildScrollView(
        //Definimos el body como SingleChildScrollView
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Form(
            //Definimos el Form como un child
            key: _formKey, //Key para activar las validaciones
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Tarjeta de instrucciones
                Card(
                  elevation: 0,
                  color: theme.colorScheme.primaryContainer.withOpacity(0.3),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          color: theme.colorScheme.primary,
                          size: 24,
                        ),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Text(
                            "Ingresa tu peso y altura para calcular tu IMC.", //Texto que vera el usuario en el appbar
                            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(
                  //Creamos el SizedBox solicitado
                  height: 24,
                ),

                TextFormField(
                  controller:
                      _pesoControlador, //Asignamos el controlador para guardar la informacion que administrara el usuario
                  keyboardType: TextInputType
                      .number, //Asignamos esta variable para que solo podamos poner numeros en los datos
                  decoration: InputDecoration(
                    //Decoracion del boton
                    labelText:
                        "Ingrese el peso (kg)", //Texto del boton ("Ingrese el peso (kg)")
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    filled: true,
                    fillColor: theme.colorScheme.primary.withOpacity(0.04),
                    prefixIcon: Icon(
                      Icons.fitness_center,
                      color: theme.colorScheme.primary,
                    ), //Icono de la pesa
                  ),
                  //Validaciones para el boton peso
                  validator: (valorPeso){
                    if (valorPeso == null ||valorPeso.isEmpty){
                      return "El peso no puede estar vacio";
                    }

                    if (valorPeso.endsWith(".")){
                      return "Formato incorrecto, el valor del peso no pueden aver . alfinal";
                    }

                    if (valorPeso.startsWith(".")){
                      return "Formato incorrrecto, el valor del peso no puede iniciar con .";
                    }

                    double ? peso = double.tryParse(valorPeso);
                    if (peso == null)
                    {
                      return "Ingrese un peso valido (numeros)";
                    }

                    if (peso <= 0){
                      return "El peso debe ser mayor a 0";
                    }

                    return null;
                  },
                ),

                const SizedBox(
                  //Creamos el SizedBox solicitado
                  height: 16,
                ),

                TextFormField(
                  controller:
                      _alturaControlador, //Asignamos el controlador para guardar la informacion que administrara el usuario
                  keyboardType: TextInputType
                      .number, //Asignamos esta variable para que solo podamos poner numeros en los datos
                  decoration: InputDecoration(
                    //Decoracion del boton
                    labelText:
                        "Ingrese la altura (m)", //Texto del boton ("Ingrese la altura (m)")
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    filled: true,
                    fillColor: theme.colorScheme.primary.withOpacity(0.04),
                    prefixIcon: Icon(
                      Icons.height,
                      color: theme.colorScheme.primary,
                    ), //Icono de la flecha
                  ),

                  //validaciones para el boton de altura
                  validator: (valorAltura){
                    if (valorAltura == null || valorAltura.isEmpty){
                      return "La altura no puede estar vacia";
                    }

                    if (!valorAltura.contains('.')){
                      return "La altura debe incluir un punto decimal\n Ejemplo: 1.75 (metros)";
                    }

                    if (valorAltura.contains(' ')){
                      return "No se permiten espacios";
                    }

                    if (valorAltura.split(".").length > 2){
                      return "Ingrese un numero decimal valido (solo un punto)";
                    }

                    if (valorAltura.startsWith(".")){
                      return "Formato incorrecto: '${valorAltura}'\nDebe escribir un número antes del punto\nEjemplo: 1.65 o 1.75";
                    }

                    if (valorAltura.endsWith(".")){
                      return "Formato incorrecto: '${valorAltura}'\nDebe escribir los decimales después del punto\nEjemplo: 1.65 o 1.72";
                    }

                    double? altura = double.tryParse(valorAltura);
                    if (altura == null)
                    {
                      return "Ingrese una altura valida (numeros)";
                    }

                    if (altura <= 0)
                    {
                      return "La altura debe de ser mayor a 0";
                    }

                    if (altura >= 5)
                    {
                      return "La altura esta muy alta, verifica que este en metros";
                    }

                    if (altura < 0.6)
                    {
                      return "La altura esta muy baja, verifica que este en metros";
                    }

                    return null;
                  },
                ),

                const SizedBox(
                  //Creamos el SizedBox solicitado
                  height: 24,
                ),

                ElevatedButton(
                  onPressed:
                      _CalcularIMC, //Llamamos al metodo que vamos ah ejecutar
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    backgroundColor: theme.colorScheme.primary,
                    foregroundColor: theme.colorScheme.onPrimary,
                    elevation: 2,
                  ),
                  child: const Text(
                    "Calcular IMC",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ), //Ponemos el texto que queremos mostrar
                ),

                if (_resultadoIMC.isNotEmpty) ...[
                  const SizedBox(
                    //Creamos el SizedBox solicitado
                    height: 32,
                  ),
                  _buildResultCard(theme),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildResultCard(ThemeData theme) {
    Color cardColor = Colors.grey;
    IconData cardIcon = Icons.help_outline;

    if (_categoria.contains("Bajo peso")) {
      cardColor = Colors.blue;
      cardIcon = Icons.info_outline;
    } else if (_categoria.contains("Peso normal")) {
      cardColor = Colors.green;
      cardIcon = Icons.check_circle_outline;
    } else if (_categoria.contains("Sobrepeso")) {
      cardColor = Colors.orange;
      cardIcon = Icons.warning_amber_outlined;
    } else if (_categoria.contains("Obesidad")) {
      cardColor = Colors.red;
      cardIcon = Icons.warning_outlined;
    }

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: cardColor.withOpacity(0.3), width: 1.5),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: [
              cardColor.withOpacity(0.04),
              cardColor.withOpacity(0.12),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 24.0),
        child: Column(
          children: [
            Icon(
              cardIcon,
              color: cardColor,
              size: 48,
            ),
            const SizedBox(height: 16),
            Text(
              _resultadoIMC,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              _categoria,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: cardColor,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

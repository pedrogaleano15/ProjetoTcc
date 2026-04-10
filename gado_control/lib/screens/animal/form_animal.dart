import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import '../../core/database/db_helper.dart';
import '../../core/services/calculos_service.dart';

class FormAnimalScreen extends StatefulWidget {
  const FormAnimalScreen({Key? key}) : super(key: key);

  @override
  _FormAnimalScreenState createState() => _FormAnimalScreenState();
}

class _FormAnimalScreenState extends State<FormAnimalScreen> {
  final _formKey = GlobalKey<FormState>();

  final _matrizController = TextEditingController();
  final _obsMaeController = TextEditingController();
  final _bezerroController = TextEditingController();
  final _loteController = TextEditingController();
  final _pastoController = TextEditingController();
  final _dataNascimentoController = TextEditingController();
  final _pesoNascimentoController = TextEditingController();

  String? _racaSelecionada;
  String? _sexoSelecionado;
  String _origem = 'Nascimento';
  bool _entradaManual = false;
  String _carimboGerado = "";

  // CORREÇÃO DO MICROFONE (Sem o late)
  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _isListening = false;
  String _textoDigitadoAntes = "";

  @override
  void initState() {
    super.initState();
    _configurarDataHoraAutomatica();
  }

  void _configurarDataHoraAutomatica() {
    setState(() {
      _entradaManual = false;
      final agora = DateTime.now();
      String d = agora.day.toString().padLeft(2, '0');
      String m = agora.month.toString().padLeft(2, '0');
      String a = agora.year.toString();
      String h = agora.hour.toString().padLeft(2, '0');
      String min = agora.minute.toString().padLeft(2, '0');
      _dataNascimentoController.text = "$d/$m/$a $h:$min";
      _carimboGerado = CalculosService.gerarCarimbo(agora);
    });
  }

  void _ouvirObservacao() async {
    if (!_isListening) {
      bool disponivel = await _speech.initialize(
        onStatus: (status) {
          if (status == 'done' || status == 'notListening')
            setState(() => _isListening = false);
        },
      );

      if (disponivel) {
        setState(() {
          _isListening = true;
          _textoDigitadoAntes = _obsMaeController.text;
        });
        _speech.listen(
          localeId: 'pt_BR',
          onResult: (resultado) {
            setState(() {
              _obsMaeController.text = _textoDigitadoAntes.isNotEmpty
                  ? "$_textoDigitadoAntes ${resultado.recognizedWords}"
                  : resultado.recognizedWords;
            });
          },
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Microfone indisponível.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } else {
      setState(() => _isListening = false);
      _speech.stop();
    }
  }

  void _salvarAnimal() async {
    if (!_formKey.currentState!.validate()) return;
    if (_sexoSelecionado == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Selecione o sexo!'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // REGRA DO BRINCO OPCIONAL
    String brincoFinal = _bezerroController.text.trim();
    if (brincoFinal.isEmpty) {
      brincoFinal =
          "SN-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}";
    }

    String identificacaoMae = _origem == 'Compra'
        ? 'Externa/Leilão'
        : (_matrizController.text.isEmpty
              ? 'Desconhecida'
              : _matrizController.text);

    final novoAnimal = {
      'mae_identificacao': identificacaoMae,
      'observacao_mae': _origem == 'Compra'
          ? 'N/A'
          : (_obsMaeController.text.isEmpty
                ? 'Sem observações'
                : _obsMaeController.text),
      'identificacao': brincoFinal,
      'raca': _racaSelecionada,
      'sexo': _sexoSelecionado,
      'data_nascimento': _dataNascimentoController.text,
      'peso_nascimento': _pesoNascimentoController.text.isEmpty
          ? 0.0
          : (double.tryParse(
                  _pesoNascimentoController.text.replaceAll(',', '.'),
                ) ??
                0.0),
      'lote': _loteController.text,
      'pasto': _pastoController.text,
      'carimbo': _carimboGerado,
      'status': 'Ativo',
    };

    try {
      await DatabaseHelper.instance.inserirAnimal(novoAnimal);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Animal registado!'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context, true);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro: O brinco $brincoFinal já está cadastrado!'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cadastrar Animal'),
        backgroundColor: Colors.green[700],
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              _buildSecaoOrigem(),
              const Divider(height: 40, thickness: 2),
              _buildSecaoMatriz(),
              const Divider(height: 40, thickness: 2),
              _buildSecaoAnimal(),
              const Divider(height: 40, thickness: 2),
              _buildSecaoNascimento(),
              const SizedBox(height: 30),
              _buildBotaoSalvar(),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSecaoOrigem() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Origem do Animal",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.blueGrey,
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          width: double.infinity,
          child: SegmentedButton<String>(
            segments: const [
              ButtonSegment(
                value: 'Nascimento',
                label: Text('Nascimento'),
                icon: Icon(Icons.child_care),
              ),
              ButtonSegment(
                value: 'Compra',
                label: Text('Compra/Leilão'),
                icon: Icon(Icons.shopping_cart),
              ),
            ],
            selected: {_origem},
            onSelectionChanged: (val) => setState(() => _origem = val.first),
          ),
        ),
      ],
    );
  }

  Widget _buildSecaoMatriz() {
    if (_origem == 'Compra') {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.orange[50],
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.orange),
        ),
        child: const Row(
          children: [
            Icon(Icons.info_outline, color: Colors.orange),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                'Animais de Compra/Leilão não exigem vínculo materno. A origem será registada como Externa.',
                style: TextStyle(color: Colors.orange),
              ),
            ),
          ],
        ),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Dados da Matriz",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.brown,
          ),
        ),
        const SizedBox(height: 10),
        TextFormField(
          controller: _matrizController,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          decoration: const InputDecoration(
            labelText: 'Número da Matriz (Opcional)',
            helperText: 'Deixe vazio se for desconhecida',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.pets),
          ),
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _obsMaeController,
          maxLines: 2,
          decoration: InputDecoration(
            labelText: 'Observações da Matriz',
            hintText: 'Ex: Brava, boa criadeira...',
            border: const OutlineInputBorder(),
            prefixIcon: const Icon(Icons.edit_note),
            suffixIcon: IconButton(
              icon: Icon(
                _isListening ? Icons.mic : Icons.mic_none,
                color: _isListening ? Colors.red : Colors.green[700],
                size: 30,
              ),
              onPressed: _ouvirObservacao,
            ),
          ),
        ),
        if (_isListening)
          const Padding(
            padding: EdgeInsets.only(top: 8.0, left: 10),
            child: Text(
              "Estou a ouvir... Fale agora!",
              style: TextStyle(
                color: Colors.red,
                fontWeight: FontWeight.bold,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildSecaoAnimal() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _origem == 'Nascimento' ? "Dados do Bezerro" : "Dados do Animal",
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.green,
          ),
        ),
        const SizedBox(height: 10),
        TextFormField(
          controller: _bezerroController,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          decoration: InputDecoration(
            labelText: _origem == 'Nascimento'
                ? 'Número do Bezerro (Opcional)'
                : 'Número do Brinco (Opcional)',
            helperText: 'Se vazio, o sistema gera uma identificação',
            border: const OutlineInputBorder(),
            prefixIcon: const Icon(Icons.tag),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _loteController,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: const InputDecoration(
                  labelText: 'Número do Lote',
                  hintText: 'Ex: 101',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.numbers),
                ),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Obrigatório' : null,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: TextFormField(
                controller: _pastoController,
                decoration: const InputDecoration(
                  labelText: 'Pasto Atual',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.grass),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        DropdownButtonFormField<String>(
          isExpanded: true,
          itemHeight: 80,
          decoration: const InputDecoration(
            labelText: 'Raça',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.category),
          ),
          value: _racaSelecionada,
          items: [
            _buildRacaItem('Nelore', 'assets/images/Nelore.jpg'),
            _buildRacaItem('Angus', 'assets/images/Angus.jpg'),
            _buildRacaItem('Cruzado', 'assets/images/Cruzado.jpg'),
          ],
          onChanged: (novoValor) =>
              setState(() => _racaSelecionada = novoValor),
          validator: (value) => value == null ? 'Obrigatório' : null,
        ),
        const SizedBox(height: 20),
        const Text('Sexo:', style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        Row(
          children: [
            _buildBotaoSexo('Macho', Icons.male, Colors.blue),
            const SizedBox(width: 16),
            _buildBotaoSexo('Fêmea', Icons.female, Colors.pink),
          ],
        ),
      ],
    );
  }

  Widget _buildBotaoSexo(String sexo, IconData icone, MaterialColor corBase) {
    bool selecionado = _sexoSelecionado == sexo;
    return Expanded(
      child: InkWell(
        onTap: () => setState(() => _sexoSelecionado = sexo),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: selecionado ? corBase[100] : Colors.grey[200],
            border: Border.all(color: selecionado ? corBase : Colors.grey),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icone, color: selecionado ? corBase[800] : Colors.grey),
              const SizedBox(width: 8),
              Text(
                sexo.toUpperCase(),
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: selecionado ? corBase[800] : Colors.grey,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSecaoNascimento() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              _origem == 'Nascimento'
                  ? "Data de Nascimento"
                  : "Data de Entrada",
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.blueGrey,
              ),
            ),
            Row(
              children: [
                const Text("Manual?"),
                Checkbox(
                  value: _entradaManual,
                  onChanged: (bool? value) {
                    setState(() {
                      _entradaManual = value!;
                      if (!_entradaManual)
                        _configurarDataHoraAutomatica();
                      else {
                        _dataNascimentoController.clear();
                        _carimboGerado = "--";
                      }
                    });
                  },
                ),
                if (_entradaManual)
                  IconButton(
                    icon: const Icon(Icons.restore, color: Colors.green),
                    onPressed: () => _configurarDataHoraAutomatica(),
                  ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 2,
              child: TextFormField(
                controller: _dataNascimentoController,
                readOnly: !_entradaManual,
                decoration: InputDecoration(
                  labelText: 'Data/Hora',
                  prefixIcon: const Icon(Icons.calendar_today),
                  border: const OutlineInputBorder(),
                  suffixIcon: _entradaManual
                      ? IconButton(
                          icon: const Icon(Icons.event),
                          onPressed: _selecionarDataManual,
                        )
                      : null,
                ),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Obrigatório' : null,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              flex: 1,
              child: Container(
                height: 58,
                decoration: BoxDecoration(
                  color: Colors.brown[100],
                  border: Border.all(color: Colors.brown),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "CARIMBO",
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: Colors.brown,
                      ),
                    ),
                    Text(
                      _carimboGerado,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _pesoNascimentoController,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: InputDecoration(
            labelText: _origem == 'Nascimento'
                ? 'Peso ao Nascer (kg) - Opcional'
                : 'Peso Compra (kg) - Opcional',
            prefixIcon: const Icon(Icons.monitor_weight),
            border: const OutlineInputBorder(),
          ),
        ),
      ],
    );
  }

  void _selecionarDataManual() async {
    DateTime? data = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (data != null) {
      TimeOfDay? hora = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );
      if (hora != null && mounted) {
        setState(() {
          String d = data.day.toString().padLeft(2, '0');
          String m = data.month.toString().padLeft(2, '0');
          String a = data.year.toString();
          String h = hora.hour.toString().padLeft(2, '0');
          String min = hora.minute.toString().padLeft(2, '0');
          _dataNascimentoController.text = "$d/$m/$a $h:$min";
          _carimboGerado = CalculosService.gerarCarimbo(data);
        });
      }
    }
  }

  Widget _buildBotaoSalvar() {
    return ElevatedButton.icon(
      onPressed: _salvarAnimal,
      icon: const Icon(Icons.save, color: Colors.white),
      label: const Padding(
        padding: EdgeInsets.all(16.0),
        child: Text(
          "Guardar Registo Completo",
          style: TextStyle(fontSize: 18, color: Colors.white),
        ),
      ),
      style: ElevatedButton.styleFrom(backgroundColor: Colors.green[800]),
    );
  }

  DropdownMenuItem<String> _buildRacaItem(String raca, String imagePath) {
    return DropdownMenuItem<String>(
      value: raca,
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: Image.asset(
              imagePath,
              width: 80,
              height: 60,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) =>
                  const Icon(Icons.broken_image, size: 60, color: Colors.grey),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              raca,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }
}

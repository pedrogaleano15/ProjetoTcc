import 'package:flutter/material.dart';

class BarraPesquisaInteligente extends StatelessWidget {
  final TextEditingController controller;
  final String tipoPesquisa;
  final Function(String) onSearch;
  final VoidCallback onClear;
  final ValueChanged<String?> onTipoChanged;

  const BarraPesquisaInteligente({
    Key? key,
    required this.controller,
    required this.tipoPesquisa,
    required this.onSearch,
    required this.onClear,
    required this.onTipoChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      color: Colors.green[800],
      child: Column(
        children: [
          Row(
            children: [
              const Text(
                'Pesquisar por: ',
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
              const SizedBox(width: 10),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: Colors.green[700],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: DropdownButton<String>(
                  value: tipoPesquisa,
                  dropdownColor: Colors.green[900],
                  underline: const SizedBox(),
                  icon: const Icon(Icons.arrow_drop_down, color: Colors.white),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                  items: ['Brinco', 'Lote']
                      .map((v) => DropdownMenuItem(value: v, child: Text(v)))
                      .toList(),
                  onChanged: onTipoChanged,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          TextField(
            controller: controller,
            onChanged: onSearch,
            style: const TextStyle(color: Colors.black),
            decoration: InputDecoration(
              hintText: tipoPesquisa == 'Brinco'
                  ? 'Digite o número do brinco...'
                  : 'Digite o número do lote...',
              prefixIcon: const Icon(Icons.search, color: Colors.green),
              suffixIcon: controller.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear, color: Colors.grey),
                      onPressed: onClear,
                    )
                  : null,
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(vertical: 0),
            ),
          ),
        ],
      ),
    );
  }
}

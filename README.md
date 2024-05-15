# Desafio Dio - **Criando um App Flutter com Gerenciamento de Estado e Reatividade** 



O Flutter é uma biblioteca de código aberto que permite criar aplicativos móveis e web usando uma única linguagem. Ele é baseado no Dart, um poderoso e moderno idioma de programação. O Flutter é rápido, flexível e fácil de usar, tornando-o uma ótima opção para desenvolvedores que desejam criar aplicativos modernos e responsivos.

Uma das principais características do Flutter é seu gerenciamento de estado reativo. Isso significa que o estado do aplicativo é atualizado automaticamente quando os dados mudam. Isso evita a necessidade de reescrever o código para atualizar o estado do aplicativo.

No Flutter, existem duas maneiras de gerenciar o estado: com o StatefulWidget e o StatelessWidget. O StatefulWidget é um widget que pode manter seu próprio estado. O StatelessWidget não pode manter seu próprio estado.

Neste tutorial, vamos mostrar como criar um aplicativo Flutter com gerenciamento de estado usando o StatefulWidget.



**Criando o Projeto Flutter**

Para começar, vamos criar um projeto Flutter. Você pode fazer isso usando o seguinte comando:



```plaintext
flutter create flutter_state_management
```

Este comando criará um novo diretório chamado `flutter_state_management`. Dentro deste diretório, você encontrará um arquivo chamado `main.dart`. Este arquivo é o ponto de entrada para seu aplicativo Flutter.



**Criando o Widget Stateful**

Agora, vamos criar um widget Stateful chamado `MyApp`. Este widget irá exibir uma lista de itens. O código para o widget `MyApp` é mostrado abaixo:



```plaintext
class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  List<String> _items = ["Item 1", "Item 2", "Item 3"];

  void _addItem() {
    setState(() {
      _items.add("New Item");
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Flutter State Management"),
      ),
      body: ListView.builder(
        itemCount: _items.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(_items[index]),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: _addItem,
      ),
    );
  }
}
```



O widget `MyApp` tem um atributo chamado `_items` que armazena uma lista de itens. O widget também tem um método chamado `_addItem()` que adiciona um novo item à lista de itens.

O widget `MyApp` também tem um método chamado `build()` que é responsável por renderizar o widget. O método `build()` usa o `ListView.builder()` para renderizar uma lista de itens. O `ListView.builder()` recebe dois parâmetros: `itemCount` e `itemBuilder`. O `itemCount` é o número de itens na lista e o `itemBuilder` é uma função que é usada para renderizar cada item na lista.



**Executando o Aplicativo Flutter**

Agora, você pode executar o aplicativo Flutter usando o seguinte comando:



```plaintext
flutter run
```

O aplicativo Flutter será aberto no seu emulador de Android ou iOS. Você deve ver uma lista de itens na tela. Você pode clicar no botão `+` para adicionar um novo item à lista.



## **Conclusão**

O Projeto cria um aplicativo Flutter com gerenciamento de estado usando o StatefulWidget. O gerenciamento de estado reativo é uma ótima maneira de manter o estado de seu aplicativo atualizado. Você pode usar o gerenciamento de estado reativo para criar aplicativos complexos e responsivos.



# App-Flutter-Getx-Android-IOS

Esse projeto foi criado apenas para prática de estudo. Um aplicativo para Android e iOS chamado "flutter getx", usando a biblioteca de gerenciamento de estado Getx. Foram cobertos os assuntos como: rota getx, gerenciamento de estado, passagem de argumentos, rotas nomeadas, criação de controladores e injeção de dependência.

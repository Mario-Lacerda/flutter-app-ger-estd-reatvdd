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


**Explicações Técnicas**

O código fornecido utiliza o Provider, uma solução de gerenciamento de estado recomendada pela equipe do Flutter. O Provider funciona com o conceito de InheritedWidget para disponibilizar dados para os widgets que necessitam.

Na classe **`TaskModel`**, usamos o **`ChangeNotifier`** para notificar os widgets ouvintes sobre quaisquer alterações no estado. Isso permite que os widgets atualizem seus UIs de acordo com as alterações de estado.

No widget `TaskList`, usamos o `Consumer` para escutar as alterações no `TaskModel`. Sempre que o estado do modelo muda, o `Consumer` reconstrói o widget `TaskList`, garantindo que a UI esteja sempre atualizada com o estado mais recente.



Como criar um App Flutter com gerenciamento de estado e reatividade:

1. Crie um novo projeto Flutter.

   

2. Adicione as seguintes dependências ao seu projeto:

   

   - flutter_bloc: Uma biblioteca para gerenciar o estado do seu aplicativo usando o padrão Bloc.

   - flutter_rxdart: Uma biblioteca para usar o Rx em Flutter.

     

3. Crie uma classe `Bloc` para gerenciar o estado do seu aplicativo.

   

4. Crie uma classe `State` para representar o estado do seu aplicativo.

   

5. Crie uma classe `Event` para representar os eventos que podem alterar o estado do seu aplicativo.

   

6. Crie uma classe `BlocBuilder` para exibir o estado do seu aplicativo na tela.

   

7. Use o `BlocProvider` para disponibilizar o `Bloc` para toda a sua aplicação.

   

8. Use o `StreamBuilder` para escutar os eventos do `Bloc` e atualizar o estado da tela.

   

Este é apenas um exemplo básico de como criar um App Flutter com gerenciamento de estado e reatividade.  Pode-se  personalizar o seu aplicativo de acordo com suas necessidades.

Para mais informações, consulte a documentação do Flutter.



#### **Aqui estão alguns passos que você pode seguir para completar o desafio:**



1. **Configuração do ambiente:**

   - Certifique-se de ter o Flutter instalado em sua máquina.

   - Crie um novo projeto Flutter usando o comando `flutter create nome_do_projeto`.

     

2. **Estrutura do projeto:**

   - Organize seu projeto em pastas (por exemplo, `lib`, `assets`, `test`, etc.).

   - Defina a estrutura de pastas para os componentes do aplicativo (telas, widgets, modelos, etc.).

     

3. **Crie as telas:**

   - Crie as telas do aplicativo (por exemplo, tela de login, tela inicial, etc.).

   - Use widgets do Flutter para criar a interface do usuário.

     

4. **Gerenciamento de estado:**

   - Escolha uma abordagem para gerenciar o estado do aplicativo (por exemplo, `Provider`, `Bloc`, `GetX`, etc.).

   - Implemente o gerenciamento de estado para atualizar os dados e a interface do usuário.

     

5. **Reatividade:**

   - Utilize widgets reativos, como `StreamBuilder`, `FutureBuilder` ou `ValueListenableBuilder`, para atualizar a interface do usuário com base nos dados do estado.

     

6. **Testes:**

   - Escreva testes unitários e de widget para garantir que seu aplicativo funcione corretamente.

   - Execute os testes usando o comando `flutter test`.

     

7. **Documentação:**

   - Documente seu código para facilitar a manutenção e colaboração futura.

     

8. **Estilização:**

   - Aplique estilos ao seu aplicativo usando temas, cores e fontes.

   - Considere usar pacotes como `google_fonts` para adicionar fontes personalizadas.

     

9. **Publicação:**

   - Quando estiver satisfeito com o aplicativo, compile-o para Android e iOS.
   - Publique o aplicativo na Google Play Store e/ou na Apple App Store.





Aqui está um exemplo aprimorado do projeto "Criando um App Flutter com Gerenciamento de Estado e Reatividade", utilizando o Provider:

## **main.dart**



```plaintext
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'task_model.dart';
import 'task_list.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => TaskModel(),
      child: MaterialApp(
        title: 'Lista de Tarefas',
        home: TaskList(),
      ),
    );
  }
}
```



### **task_model.dart**



```plaintext
import 'package:flutter/foundation.dart';

class TaskModel with ChangeNotifier {
  List<String> _tasks = [];

  List<String> get tasks => _tasks;

  void addTask(String task) {
    _tasks.add(task);
    notifyListeners();
  }

  void removeTask(int index) {
    _tasks.removeAt(index);
    notifyListeners();
  }
}
```



## task_list.dart



```plaintext
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'task_model.dart';

class TaskList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Lista de Tarefas'),
      ),
      body: Consumer<TaskModel>(
        builder: (context, taskModel, child) {
          return ListView.builder(
            itemCount: taskModel.tasks.length,
            itemBuilder: (context, index) {
              return ListTile(
                title: Text(taskModel.tasks[index]),
                trailing: IconButton(
                  icon: Icon(Icons.delete),
                  onPressed: () {
                    taskModel.removeTask(index);
                  },
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: Text('Adicionar Tarefa'),
                content: TextField(
                  onSubmitted: (value) {
                    taskModel.addTask(value);
                    Navigator.pop(context);
                  },
                ),
              );
            },
          );
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
```

Este projeto aprimorado inclui um recurso para adicionar novas tarefas, demonstrando ainda mais o uso do gerenciamento de estado com o Provider.



## **Conclusão**

Este projeto demonstra como criar um aplicativo Flutter com gerenciamento de estado reativo usando o Provider. O Provider é uma ferramenta simples e eficaz para gerenciar o estado em aplicativos Flutter, permitindo que você construa aplicativos responsivos e fáceis de manter. 

O Projeto cria um aplicativo Flutter com gerenciamento de estado usando o StatefulWidget. O gerenciamento de estado reativo é uma ótima maneira de manter o estado de seu aplicativo atualizado. Você pode usar o gerenciamento de estado reativo para criar aplicativos complexos e responsivos.



## **Aplicabilidade**

O gerenciamento de estado reativo é uma técnica essencial para construir aplicativos Flutter eficientes e escaláveis. Ele permite que você gerencie o estado do aplicativo de forma centralizada, evitando problemas comuns como a passagem de props profundamente aninhados e o uso de `setState` em vários widgets.

Você pode aplicar o gerenciamento de estado reativo em vários tipos de aplicativos Flutter, incluindo:

- Aplicativos de gerenciamento de dados, como listas de tarefas, agendas e aplicativos de compras
- Aplicativos de streaming de dados, como aplicativos de bate-papo e aplicativos de mídia social
- Aplicativos com lógica de negócios complexa, onde o estado precisa ser compartilhado entre vários widgets
- Aplicativos que requerem alta capacidade de resposta e atualizações de UI em tempo real



Ao utilizar o gerenciamento de estado reativo, você pode criar aplicativos Flutter mais robustos, fáceis de manter e que fornecem uma ótima experiência ao usuário.








# App-Flutter-Getx-Android-IOS

Esse projeto foi criado apenas para prática de estudo. Um aplicativo para Android e iOS chamado "flutter getx", usando a biblioteca de gerenciamento de estado Getx. Foram cobertos os assuntos como: rota getx, gerenciamento de estado, passagem de argumentos, rotas nomeadas, criação de controladores e injeção de dependência.

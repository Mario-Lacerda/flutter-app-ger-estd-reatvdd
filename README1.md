# Desafio Dio - **Criando um App Flutter com Gerenciamento de Estado e Reatividade** 



### Por que usar o Cloud Firestore?

O conjunto de tecnologias do [FlutterFire](https://firebase.flutter.dev/), composto pelo Flutter e pelo Firebase (e, especificamente pelo Cloud Firestore), desbloqueia uma velocidade de desenvolvimento sem precedentes durante a criação e o lançamento de aplicativos. Neste artigo, vamos explorar a integração robusta dessas duas tecnologias, com foco nos testes e no uso de padrões arquitetônicos limpos. No entanto, em vez de passar direto para a implementação final, vamos percorrer o caminho, passo a passo, para que a lógica por trás de cada etapa fique clara.

### O que vamos criar

Para demonstrar uma forma limpa de implementar o Cloud Firestore como o back-end do aplicativo, vamos criar uma versão modificada do aplicativo contador clássico do Flutter. A única diferença é que o carimbo de data/hora de cada clique é armazenado no Cloud Firestore, e a contagem exibida é derivada do número de carimbos de data/hora mantidos. Você usará o Provider e o ChangeNotifier para manter o código de dependências e gerenciamento de estados limpo, e atualizará o teste gerado para manter o código *correto*.



### Antes de começar

Este artigo supõe que você já [assistiu e seguiu as etapas deste tutorial](https://www.youtube.com/watch?v=Mx24wiPilHg) para integrar o aplicativo ao Firebase. Resumo:

1. Crie um novo projeto do Flutter e nomeie-o como firebasecounter.
2. Crie um aplicativo Firebase [no Console do Firebase](https://console.firebase.google.com/).
3. Vincule o aplicativo ao iOS e/ou Android, dependendo do ambiente para desenvolvedores e do público-alvo.

> Observação: se você configurar o aplicativo para funcionar em um cliente Android, terá que [criar um ](https://gist.github.com/henriquemenezes/70feb8fff20a19a65346e48786bedb8f)[arquivo debug.keystore](https://gist.github.com/henriquemenezes/70feb8fff20a19a65346e48786bedb8f) antes de gerar o certificado SHA1.

Após a geração dos aplicativos iOS ou Android no Firebase, você estará pronto para continuar. O restante do vídeo traz um ótimo conteúdo, do qual você provavelmente precisará nos projetos reais, mas isso não é necessário para este tutorial.



### Caso você encontre obstáculos

Se qualquer uma das etapas deste tutorial não funcionar para você, consulte [este repositório público](https://github.com/craiglabenz/flutter-firestore-counter), que detalha as mudanças em diferentes commits. Ao longo do tutorial, você encontrará links para cada commit, quando apropriado. Sinta-se à vontade para usar essa função a fim de verificar se está progredindo da forma esperada!



### Criação de um gerenciador de estados simples



Para começar o processo de integração do aplicativo com o Cloud Firestore, você deve primeiro refatorar o código gerado, para que o StatefulWidget inicial se comunique com uma classe separada, em vez de com seus próprios atributos. Isso permite que você, eventualmente, instrua essa classe separada a usar o Cloud Firestore.

Ao lado do arquivo main.dart gerado automaticamente para o projeto, crie um novo arquivo chamado counter_manager.dart e copie para ele o seguinte código:

```
class CounterManager {
  /// Create a private integer to store the count. Make this private
  /// so that Widgets can't modify it directly, but instead must 
  /// use official methods.
  int _count = 0;
  /// Publicly accessible reference to our state.
  int get count => _count;
  /// Publicly accessible state mutator.
  void increment() => _count++;
}
```



Com esse código inserido, adicione a seguinte linha ao início do arquivo firebasecounter/lib/main.dart:

```
import 'package:firebasecounter/counter_manager.dart';
```



Depois, altere o código de _MyHomePageState para:

```
class _MyHomePageState extends State<MyHomePage> {
  final manager = CounterManager();
  void _incrementCounter() {
    setState(() => manager.increment());
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text('You have pushed the button this many times:'),
            Text(
              '${manager.count}',
              style: Theme.of(context).textTheme.headline4,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: Icon(Icons.add),
      ),
    );
  }
}
```



Depois de salvar a mudança do código, talvez pareça que o aplicativo falhou, pois ele mostrará uma tela de erro vermelha. Isso é porque você introduziu uma nova variável, manager, cuja oportunidade de inicialização já passou. Essa é uma experiência comum no Flutter, quando a forma como o estado *é inicializado*muda, e a questão pode ser facilmente resolvida com uma reinicialização a quente.

Após a reinicialização a quente, você deverá voltar para o ponto inicial: na contagem 0 e capaz de clicar no botão de ação flutuante o quanto quiser.



Esse é um bom momento para executar o único teste que o Flutter fornece em qualquer novo projeto. A definição dele pode ser encontrada em test/widget_test.dart, e ele pode ser executado com o seguinte comando:

```
$ flutter test
```



Se o teste for bem-sucedido, você estará pronto para continuar!

> Observação: caso você encontre obstáculos nesta seção, compare suas mudanças com [este commit](https://github.com/craiglabenz/flutter-firestore-counter/commit/483dd3b3833bf710b04db4a3ba347b1d1ecbe5de) no repositório do tutorial.



### Manutenção dos carimbos de data/hora



A descrição inicial do aplicativo mencionava a manutenção do carimbo de data/hora de cada clique. Até agora, você não adicionou nenhuma infraestrutura para atender a esse segundo requisito, portanto, crie um novo arquivo chamado app_state.dart e adicione a seguinte classe:

```
/// Container for the entirety of the app's state. An instance of 
/// this class should be able to inform what is rendered at any
/// point in time.
class AppState {
  /// Full click history. For super important auditing purposes.
  /// The count of clicks becomes this list's `length` attribute.
  final List<DateTime> clicks;
  /// Default generative constructor. Const-friendly, for optimal 
  /// performance.
  const AppState([List<DateTime> clicks])
      : clicks = clicks ?? const <DateTime>[];
      
  /// Convenience helper.
  int get count => clicks.length;
  /// Copy method that returns a new instance of AppState instead
  /// of mutating the existing copy.
  AppState copyWith(DateTime latestClick) => AppState([
    latestClick,
    ...clicks,
  ]);
}
```



A partir deste ponto, a função da classe AppState é representar o estado do que deve ser renderizado. A classe não contém nenhum método que possa sofrer mutações, apenas um único método copyWith, que será utilizado pelas outras classes.



Com os testes em mente, você pode começar a fazer mudanças no conceito do CounterManager. Ter uma única classe não será suficiente no longo prazo, porque o aplicativo eventualmente interage com o Cloud Firestore. Mas não é preciso criar registros reais todas as vezes que um teste é executado. Para isso, é necessária uma interface abstrata que defina como o aplicativo deve se comportar.



Abra o arquivo counter_manager.dart novamente e adicione o seguinte código no início do arquivo:

```
import 'package:firebasecounter/app_state.dart';
/// Interface that defines the functions required to manipulate
/// the app state.
///
/// Defined as an abstract class so that tests can operate on a 
/// version that does not communicate with Firebase.
abstract class ICounterManager {
  /// Any `CounterManager` must have an instance of the state 
  /// object.
  AppState state;
  /// Handler for when a new click must be stored. Does not require 
  /// any parameters, because it only causes the timestamp to 
  /// persist.
  void increment();
}
```



A próxima etapa é atualizar o CounterManager para descender explicitamente do ICounterManager. Atualize a definição dele da seguinte forma:

```
class CounterManager implements ICounterManager {
  AppState state = AppState();
  void increment() => state = state.copyWith(DateTime.now());
}
```



Neste ponto, nosso código auxiliar parece muito bom, mas o main.dart ficou para trás. Não há referência ao ICounterManager no main.dart, quando, na verdade, essa é a *única* classe Manager que ele deve conhecer. No main.dart, faça as seguintes mudanças:



1. Adicione o import que falta ao início do arquivo main.dart:

```
import 'package:firebasecounter/app_state.dart';
```



2. Atualize _MyHomePageState da seguinte forma:

```
class _MyHomePageState extends State<MyHomePage> {
  final ICounterManager manager;
  _MyHomePageState({@required this.manager});
  void _incrementCounter() => setState(() => manager.increment());
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text('You have pushed the button this many times:'),
            Text(
              '${manager.state.count}',
              style: Theme.of(context).textTheme.headline4,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: Icon(Icons.add),
      ),
    );
  }
}
```



Essa mudança deve remover todas as linhas vermelhas sublinhadas do ambiente de desenvolvimento integrado de _MyHomePageState. Mas, agora, MyHomePage está reclamando, porque seu método createState() não fornece todos os argumentos necessários para _MyHomePageState. Você pode fazer com que MyHomePage solicite essa variável e transmita o objeto para sua classe baseada em estado, mas isso geraria longas cadeias de widgets solicitando e transmitindo objetos que não são realmente importantes para eles, simplesmente porque um widget descendente está exigindo e um widget ancestral está fornecendo. Claramente, isso requer uma estratégia melhor.

É aí que entra o [Provider](https://pub.dev/packages/provider).



### Como usar o Provider para acessar o estado do aplicativo



O Provider é uma biblioteca que otimiza o uso do padrão InheritedWidget do Flutter. Ele permite que um widget no topo da árvore de widgets seja acessível diretamente por todos os seus descendentes. Isso pode parecer similar a uma variável global, mas a alternativa é transmitir os modelos de dados por cada um dos widgets intermediários, quando muitos deles não terão nenhum interesse intrínseco por esses modelos. Esse antipadrão no estilo de “[brigada de baldes](https://en.wikipedia.org/wiki/Bucket_brigade) de variáveis” ofusca a separação dos interesses do aplicativo e pode tornar os layouts de refatoração desnecessariamente enfadonhos. O InheritedWidget e o Provider ignoram esses problemas permitindo que os widgets em qualquer ponto da árvore obtenham diretamente os modelos de dados de que necessitam.



Para adicionar o Provider ao aplicativo, abra o pubspec.yaml e adicione-o abaixo da seção dependencies:

```
dependencies:
  flutter:
    sdk: flutter
  # Add this
  provider: ^4.3.2+2
```

Depois de adicionar essa linha ao arquivo pubspec.yaml, execute o seguinte para fazer o download do Provider para a máquina:

```
$ flutter pub get
```



Ao lado do main.dart, crie um novo arquivo chamado dependencies.dart e copie para ele o seguinte código:

```
import 'package:firebasecounter/counter_manager.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
class DependenciesProvider extends StatelessWidget {
  final Widget child;
  DependenciesProvider({@required this.child});
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<ICounterManager>(create: (context) => CounterManager()),
      ],
      child: child,
    );
  }
}
```



Algumas observações sobre o DependenciesProvider:



1. Ele usa o MultiProvider, apesar de ter apenas uma entrada na lista. Isso, tecnicamente, poderia ser recolhido em um único widget Provider, mas um aplicativo real provavelmente conterá muitos desses serviços, por isso geralmente é melhor começar com o MultiProvider, de qualquer forma.

   

2. Ele requer um widget filho, que segue a convenção do Flutter para a composição de widgets e permite inserir esse auxiliar perto to topo da árvore de widgets, disponibilizando a instância do ICounterManager para todo o aplicativo.



Em seguida, disponibilize o novo DependenciesProvider para todo o aplicativo. Uma forma simples de fazer isso é agrupar todo o widget MaterialApp com ele. Abra o main.dart e atualize o método principal da seguinte maneira:

```
void main() {
  runApp(
    DependenciesProvider(child: MyApp()),
  );
}
```

Também é preciso importar o dependencies.dart para o main.dart:

```
import 'package:firebasecounter/dependencies.dart';
```



### Como usar um widget Consumer

Já vimos o widget MultiProvider em ação (que é, na verdade, apenas uma forma mais bacana de declarar uma série de widgets Provider individuais). O próximo passo é acessar o objeto ICounterManager usando o widget [Consumer](https://pub.dev/documentation/provider/latest/provider/Consumer-class.html).



### Injeção de dependências



Se você já escreveu um aplicativo Flutter usando o Cloud Firestore, provavelmente descobriu que o Firestore pode tornar mais complicado escrever bons testes de unidade. Afinal, como evitar gerar registros reais no banco de dados quando uma integração do Firestore é conectada diretamente à árvore de widgets?

Se você já teve essa experiência, já sabe das limitações para a incorporação de dependências diretamente no código da IU, que são os widgets, no caso do Flutter. Esse é o poder da injeção de dependências: se os widgets aceitarem classes auxiliares que facilitam sua interação com as dependências (como o Firebase, o sistema de arquivos do dispositivo ou mesmo as solicitações de rede), você pode fornecer itens fictícios ou falsos em vez das classes reais durante os testes. Com isso, é possível testar se os widgets se comportam como deveriam sem precisar esperar por solicitações lentas de rede, encher o sistema de arquivos ou incorrer em taxas de faturamento do Firebase.

Para conseguir isso, você precisa refatorar o aplicativo para que haja um ponto limpo no qual os testes possam injetar itens falsos que imitem o comportamento real do Cloud Firestore. Felizmente, o widget Consumer é perfeito para o trabalho.



Abra o main.dart e substitua o widget MyApp pelo seguinte código:

```
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: Consumer<ICounterManager>(
        builder: (context, manager, _child) => MyHomePage(
          manager: manager,
          title: 'Flutter Demo Home Page',
        ),
      ),
    );
  }
}
```



Além disso, importe o Provider para o início do main.dart:

```
import 'package:provider/provider.dart';
```

O agrupamento de MyHomePage em um widget Consumer permite chegar arbitrariamente alto na árvore de widgets para acessar os recursos desejados e injetá-los nos widgets que precisam deles. Esse pode parecer um trabalho desnecessário neste tutorial, porque você só precisa voltar uma camada até o MyApp(), mas isso pode abranger dezenas widgets em aplicativos reais.

Em seguida, no mesmo arquivo, faça esta edição em MyHomePage:

> Observação: não se preocupe se vir uma tela vermelha depois de salvar essa mudança. Mais edições são necessárias para concluir a refatoração.

```
class MyHomePage extends StatefulWidget {
  final ICounterManager manager;
  MyHomePage({@required this.manager, Key key, this.title}) : super(key: key);
  final String title;
  @override
  _MyHomePageState createState() => _MyHomePageState();
}
```

Essa mudança simples de construtor permite que o código aceite a variável transmitida no snippet anterior.

Por fim, conclua a refatoração fazendo esta edição em _MyHomePageState:

```
class _MyHomePageState extends State<MyHomePage> {
  // No longer expect to receive a `ICounterManager object`
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text('You have pushed the button this many times:'),
            Text(
              // Reference `widget.manager` instead of
              // `manager` directly
              '${widget.manager.state.count}',
              style: Theme.of(context).textTheme.headline4,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        // Reference `widget.manager` instead of `manager` directly
        onPressed: () => setState(() => widget.manager.increment()),
        tooltip: 'Increment',
        child: Icon(Icons.add),
      ),
    );
  }
}
```

> Observação: provavelmente será necessária uma reinicialização a quente para corrigir o aplicativo.

Como você deve se lembrar, todos os objetos State contêm uma referência para seus wrappers StatefulWidget no atributo widget. Portanto, o objeto _MyHomePageState pode acessar esse novo atributo manager mudando seu código de manager para widget.manager.

Pronto! Você injetou dependências nos widgets que precisam delas, em vez de fixar implementações de produção no código.



### Teste o aplicativo



Se você executar o teste do Flutter agora mesmo, verá que o pacote de teste não é mais bem-sucedido. Quando você inspecionar o widget_test.dart, o motivo deve ser claro: a função de teste instancia o MyApp(), mas não o agrupa com o DependenciesProvider como você fez no código real. Por isso, o widget Consumer adicionado dentro do MyApp não consegue encontrar um Provider satisfatório em seus widgets ancestrais.

É nesse ponto que a injeção de dependências começa a demonstrar seus benefícios. Em vez de imitar o código de produção nos testes (agrupando o MyApp com o DependenciesProvider), altere o teste para inicializar o MyHomePage. Atualize o widget_test.dart da seguinte maneira:

```
import 'package:firebasecounter/counter_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:firebasecounter/main.dart';
void main() {
  testWidgets('Counter increments smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(
      MaterialApp(
        home: MyHomePage(
          manager: CounterManager(),
          title: 'Test Widget',
        ),
      ),
    );
    // Verify that our counter starts at 0.
    expect(find.text('0'), findsOneWidget);
    expect(find.text('1'), findsNothing);
    // Tap the '+' icon and trigger a frame.
    await tester.tap(find.byIcon(Icons.add));
    await tester.pump();
    // Verify that our counter has incremented.
    expect(find.text('0'), findsNothing);
    expect(find.text('1'), findsOneWidget);
  });
}
```

Com o uso direto de uma instância de MyHomePage (juntamente com o agrupamento do MaterialApp para fornecer objetos BuildContext válidos), você configurou uma integração com teste de unidade com o Cloud Firestore!

> Observação: caso você encontre obstáculos nesta seção, compare suas mudanças com [este commit](https://github.com/craiglabenz/flutter-firestore-counter/commit/bb68c1d3bb3746eca5f2dea16bd799c98ff232f1) no repositório do tutorial.



### Implementação do Cloud Firestore

Até agora, você passou por um monte de códigos e introduziu várias classes auxiliares, mas não mudou nada no funcionamento do aplicativo. A boa notícia é que tudo está preparado para começar a escrever o código que reconhece o Cloud Firestore. Para começar, abra o pubspec.yaml e adicione estas duas linhas:

```
dependencies:
  # Add this
  cloud_firestore: ^0.14.1
  # Add this
  firebase_core: ^0.5.0
  flutter:
    sdk: flutter
  provider: ^4.3.2+2
```

Como sempre, quando se aplica mudanças ao pubspec.yaml (a menos que o ambiente de desenvolvimento integrado faça isso por você), é preciso executar o seguinte comando para fazer o download e vincular as novas bibliotecas:

```
$ flutter pub get
```

> Observação: se você ainda não tiver criado o banco de dados, acesse o Console do Firebase do projeto, clique na guia **Cloud Firestore** e clique no botão **Create Database**.



## A espera pelo Firebase



A primeira etapa para usar com êxito o Cloud Firestore é inicializar o Firebase e, o mais importante, *não tentar usar nenhum recurso do Firebase até que essa tarefa tenha sido realizada com êxito*. Por sorte, você pode conter essa lógica com um StatefulWidget em vez de espalhar isso por todo o código.

Crie um novo arquivo em firebasecounter/lib/firebase_waiter.dart e adicione o seguinte código:

```
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
class FirebaseWaiter extends StatefulWidget {
  final Widget Function(BuildContext) builder;
  final Widget waitingChild;
  const FirebaseWaiter({
    @required this.builder,
    this.waitingChild,
    Key key,
  }) : super(key: key);
  @override
  _FirebaseWaiterState createState() => _FirebaseWaiterState();
}
class _FirebaseWaiterState extends State<FirebaseWaiter> {
  Future<FirebaseApp> firebaseReady;
  @override
  void initState() {
    super.initState();
    firebaseReady = Firebase.initializeApp();
  }
  @override
  Widget build(BuildContext context) => FutureBuilder<FirebaseApp>(
        future: firebaseReady,
        builder: (context, snapshot) => //
            snapshot.connectionState == ConnectionState.done
                ? widget.builder(context)
                : widget.waitingChild,
      );
}
```

Essa classe usa o padrão do Flutter de aproveitar determinados widgets para lidar completamente com uma dependência ou um problema específico dentro do aplicativo. Para usar esse widget FirebaseWaiter, volte ao main.dart e aplique a seguinte mudança em MyApp:

```
// Add this import at the top
import 'package:firebasecounter/firebase_waiter.dart';
// Replace `MyApp` with this
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: FirebaseWaiter(
        builder: (context) => Consumer<ICounterManager>(
          builder: (context, manager, _child) => MyHomePage(
            manager: manager,
            title: 'Flutter Demo Home Page',
          ),
        ),
        // This is a great place to put your splash page!
        waitingChild: Scaffold(
          body: const Center(child: CircularProgressIndicator()),
        ),
      ),
    );
  }
}
```

Agora, o aplicativo pode aguardar pela inicialização do Firebase, mas pode ignorar esse processo durante os testes simplesmente não utilizando o FirebaseWaiter.

> Observação: as mudanças acima podem fazer com que o Flutter reclame pela ausência de plug-ins do Firebase. Se isso acontecer, encerre completamente o aplicativo e reinicie a depuração, para que o Flutter possa instalar todas as dependências específicas de plataforma.



## Como obter dados do Cloud Firestore



Primeiro, importe o Cloud Firestore adicionando a seguinte linha ao início do counter_manager.dart:

```
import 'package:cloud_firestore/cloud_firestore.dart';
```

Em seguida, também no counter_manager.dart, adicione a seguinte classe:

```
class FirestoreCounterManager implements ICounterManager {
  AppState state;
  final FirebaseFirestore _firestore;
FirestoreCounterManager()
      : _firestore = FirebaseFirestore.instance,
        state = const AppState() {
    _watchCollection();
  }
void _watchCollection() {
    // Part 1
    _firestore
        .collection('clicks')
        .snapshots()
        // Part 2
        .listen((QuerySnapshot snapshot) {
      // Part 3
      if (snapshot.docs.isEmpty) return;
      // Part 4
      final _clicks = snapshot.docs
          .map<DateTime>((doc) {
            final timestamp = doc.data()['timestamp'];
            return (timestamp != null)
                ? (timestamp as Timestamp).toDate()
                : null;
          })
          // Part 5
          .where((val) => val != null)
          // Part 6
          .toList();
      // Part 7
      state = AppState(_clicks);
    });
  }
  @override
  void increment() {
    _firestore.collection('clicks').add({
      'timestamp': FieldValue.serverTimestamp(),
    });
  }
}
```

> Observação: essa classe é quase correta, mas cria um bug que será explorado mais adiante. Se você adicionar esse código ao aplicativo e executá-lo agora, verá que o comportamento não é o que você desejava. Continue lendo para ver uma explicação completa do que está acontecendo.



Há muitas coisas acontecendo aqui, então, vamos falar sobre elas.

Primeiro, o FirestoreCounterManager implementa a interface do ICounterManager, por isso ele é um candidato qualificado para uso em widgets de produção. (Eventualmente, ele receberá o byDependenciesProvider.) O FirestoreCounterManager também mantém uma instância do FirebaseFirestore, que é a conexão ao vivo com o banco de dados de produção. Além disso, o FirestoreCounterManager chama _watchCollection() durante sua inicialização para configurar uma conexão com os dados específicos nos quais você está interessado, e é neste ponto que as coisas ficam interessantes.

O método _watchCollection() é muito útil e merece um exame mais cuidadoso.

**Na Parte 1**, _watchCollection() chama _firestore.collection('clicks').snapshots(), que retorna um stream de atualizações sempre que há uma mudança nos dados de hora da coleção.



**Na Parte 2, _**watchCollection() registra imediatamente um listener para esse stream utilizando .listen(). A callback transmitida para listen() recebe um novo objeto QuerySnapshot em cada mudança dos dados. Esse objeto de atualização é chamado de instantâneo porque reflete o estado correto do banco de dados em um determinado momento, mas pode ser substituído por um novo instantâneo a qualquer ponto.

Na Parte 3, a callback entra em curto-circuito se a coleção estiver vazia.

Na Parte 4, a callback faz o loop para os documentos do instantâneo e retorna uma lista de valores nulos e DateTime combinados.

Na Parte 5, a callback descarta todos os valores nulos. Esses valores vêm do bug que será corrigido em breve, mas esse tipo de codificação defensiva é sempre uma boa ideia quando estamos lidando com dados do Cloud Firestore.

Na Parte 6, a callback lida com o fato de que map() retorna um iterador, não uma lista. A chamada de .toList() em um iterador o força a processar toda a coleção, que é aquilo que desejamos fazer.

E, por fim, na Parte 7, a callback atualiza o objeto state.

Para usar a nova classe, abra o dependencies.dart e substitua o conteúdo do arquivo pelo seguinte:

```
import 'package:firebasecounter/counter_manager.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
class DependenciesProvider extends StatelessWidget {
  final Widget child;
  DependenciesProvider({@required this.child});
@override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<ICounterManager>(
            create: (context) => FirestoreCounterManager()),
      ],
      child: child,
    );
  }
}
```



### Diagnóstico do bug

Se você executar esse código como está, poderá *quase* ver o comportamento desejado. Tudo parece correto, com a exceção de que a tela sempre é renderizada um clique atrás da realidade. O que está acontecendo?

O problema vem de uma incompatibilidade entre a implementação inicial do contador e a implementação atual, baseada em stream. O gerenciador onPressed do FloatingActionButton tem a seguinte aparência:

```
floatingActionButton: FloatingActionButton(
  onPressed: () => setState(() => widget.manager.increment()),
  ...
)
```

Esse gerenciador chama increment() e invoca imediatamente setState(), que instrui o Flutter a renderizar novamente.

Isso funcionava bem durante a atualização síncrona de estados mantidos na memória do dispositivo. No entanto, a nova implementação baseada em stream inicia uma série etapas assíncronas. Isso significa que, da forma como está, o código chama setState() imediatamente, depois, apenas em um ponto desconhecido no futuro, o objeto manager atualiza seu atributo de estado. Em resumo, a chamada a setState() no gerenciador onPressed está ocorrendo cedo demais. E, o que é pior, uma vez que toda essa atividade ocorre dentro de uma callback, dentro do FirestoreCounterManager, sobre o qual os widgets não sabem nada, não há um Future pelo qual os widgets possam aguardar para solucionar o problema.

É quase como se o objeto manager precisasse ser capaz de dizer aos widgets quando redesenhar. 🤔

É aí que entra o [ChangeNotifier](https://flutter.dev/docs/development/data-and-backend/state-mgmt/simple#changenotifier).

> Observação: caso você encontre obstáculos nesta seção, compare suas mudanças com [este commit](https://github.com/craiglabenz/flutter-firestore-counter/commit/3bf17b9bfac6c907b8650e1c668fa19b1160a51d) no repositório público. Elas incluem mudanças do Xcode e do build.gradle resultantes da adição do Firebase, mas você provavelmente pode se concentrar mais nas mudanças dos arquivos Dart.





## Como usar ChangeNotifier para renderizar novamente a árvore de widgets



ChangeNotifier é uma classe que faz exatamente o que seu nome sugere: notifica os widgets quando ocorrem mudanças que exigem uma nova renderização.

A primeira etapa do processo é atualizar a interface do ICounterManager para estender ChangeNotifier. Para isso, abra firebasecounter/lib/counter_manager.dart e faça as seguintes mudanças na declaração ICounterManager:

```
// Add `extends ChangeNotifier` to your declaration
abstract class ICounterManager extends ChangeNotifier {
  // Everything inside the class is the same.
}
```

Se você ainda não tiver importado o flutter/material.dart, abra firebasecounter/lib/counter_manager.dart e adicione-o ao início:

```
import 'package:flutter/material.dart';
```

Agora, você está pronto para atualizar as definições de CounterManager e FirestoreCounterManager. Para o CounterManager, substitua seu código pela seguinte implementação:

```
class CounterManager extends ChangeNotifier implements ICounterManager {
  AppState state = AppState();
  /// Copies the state object with the timestamp of the most
  /// recent click and tells the stream to update.
  void increment() {
    state = state.copyWith(DateTime.now());
    // Adding this line is how `ChangeNotifier` tells widgets to
    // re-render themselves.
    notifyListeners();
  }
}
```

E, para o FirebaseCounterManager, aplique as seguintes mudanças:

1. Edite sua assinatura de acordo com o seguinte:

```
class FirestoreCounterManager extends ChangeNotifier
    implements ICounterManager {
    ...
}
```

2. Adicione a mesma linha notifyListeners(); ao final de _watchCollection(), da seguinte maneira:

```
void _watchCollection() {
  _firestore
      .collection('clicks')
      .snapshots()
      .listen((QuerySnapshot snapshot) {
      
    // Generation of `_clicks` omitted for clarity, but do not
    // change that code.
    state = AppState(_clicks);
    
    // The only change necessary is to add this line!
    notifyListeners();
  });
}
```

Agora, você já configurou metade das mudanças necessárias para que as classes do ICounterManager instruam os widgets a renderizar novamente sempre que os dados mudarem. As classes Manager estão instruindo os widgets a renderizar novamente, mas, se você executar o aplicativo agora, verá que os widgets não estão ouvindo.

Para corrigir isso, abra o dependencies.dart e substitua a implementação de DependenciesProvider pelo seguinte:

```
class DependenciesProvider extends StatelessWidget {
  final Widget child;
  DependenciesProvider({@required this.child});
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // `Provider` has been replaced by ChangeNotifierProvider
        ChangeNotifierProvider<ICounterManager>(
          create: (context) => FirestoreCounterManager(),
        ),
      ],
      child: child,
    );
  }
}
```

Como última mudança, remova setState de _MyHomePageState para ignorar qualquer nova renderização desnecessária. Atualize FloatingActionButton desta forma:

```
      floatingActionButton: FloatingActionButton(
        // Remove setState()!
        onPressed: widget.manager.increment,
        tooltip: 'Increment',
        child: Icon(Icons.add),
      ),
```

Pronto! O ChangeNotifierProvider garante que os widgets sejam “listeners”, para que, quando notifyListeners() for chamado por uma classe do ICounterManager, os widgets recebam a mensagem para fazer a renderização novamente.

Neste ponto, você deve ser capaz de reiniciar a quente o aplicativo e ver tudo funcionando corretamente.

Observação: caso você encontre obstáculos nesta seção, compare suas mudanças com [este commit](https://github.com/craiglabenz/flutter-firestore-counter/commit/dfb584f62d094d8fdb6067ea11ff3551b9186aed) no repositório público.



## Correção dos testes

Embora a última rodada de mudanças tenha implementado com êxito a funcionalidade desejada, infelizmente, ela também prejudicou os testes. Em seguida, você aplicará alguns ajustes adicionais para que tudo funcione novamente, e assim, terá terminado.

No widget_test.dart, o código transmite uma instância do CounterManager diretamente sem um ChangeNotifierListener auxiliar. A forma como isso era tratado na árvore de widgets era agrupando tudo no DependenciesProvider, mas essa classe tem conhecimento do Firestore, e o objetivo disto tudo é manter o Firestore de fora dos testes.

Uma solução é criar o TestDependenciesProvider, que pode conter as versões de teste de todas as dependências. Abra firebasecounter/lib/dependencies.dart e adicione a seguinte classe:

```
class TestDependenciesProvider extends StatelessWidget {
  final Widget child;
  TestDependenciesProvider({@required this.child});
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<ICounterManager>(
          create: (context) => CounterManager(),
        ),
      ],
      child: child,
    );
  }
}
```

Essa classe é quase idêntica ao DependenciesProvider, mas o TestDependenciesProvider fornece uma instância de CounterManager() em vez de FirestoreCounterManager().

Agora, em test/widget_test.dart, atualize a inicialização do widget de teste para:

```
await tester.pumpWidget(
  TestDependenciesProvider(
    child: MaterialApp(
      home: Consumer<ICounterManager>(
        builder: (context, manager, _child) => MyHomePage(
          manager: manager,
          title: 'Flutter Test Home Page',
        ),
      ),
    ),
  ),
);
```

Se ainda não tiver feito isso, adicione estes dois imports perto do início do test/widget_test.dart:

```
import 'package:firebasecounter/dependencies.dart';
import 'package:provider/provider.dart';
```

Execute os teste novamente e... pronto!

Observação: caso você encontre obstáculos nesta seção, compare suas mudanças com [este commit](https://github.com/craiglabenz/flutter-firestore-counter/commit/cb8c876abfa80b013bb122ed289163ab5587f5cc) no repositório público.

### Conclusão

Neste artigo, você remodelou o aplicativo contador clássico do Flutter para que ele mantenha toda a atividade no Cloud Firestore. Também evitou misturar a lógica de negócios com os widgets, o que facilita o teste do aplicativo.

As técnicas de gerenciamento de estados discutidas aqui são viáveis para muitos aplicativos, mas não são as únicas formas de se fazer isso, nem as melhores. A comunidade do Flutter está repleta de excelentes soluções de gerenciamento de estados que valem uma investigação. Estas são algumas a serem consideradas:

1. O [Flutter Bloc](https://pub.dev/packages/flutter_bloc) é particularmente útil para quem tem experiência com o [Redux](https://redux.js.org/).
2. Esta [série de tutoriais de vídeo do Flutter Firebase e DDD](https://www.youtube.com/playlist?list=PLB6lc7nQ1n4iS5p-IezFFgqP6YvAJy84U), da [Reso Coder](https://www.youtube.com/resocoder), fornece instruções passo a passo de todo o processo de uso do Flutter Bloc, do Cloud Firestore e de várias outras excelentes bibliotecas.
3. Esta [porta mais direta do Redux](https://pub.dev/packages/flutter_redux) também é muito utilizada.
4. O item mais recente da lista: o criador do Provider lançou um novo pacote, o [Riverpod](https://pub.dev/packages/riverpod), que é o sucessor do Provider.

Para obter mais informações sobre gerenciamento de estados, consulte os [documentos sobre gerenciamento de estados](https://flutter.dev/docs/development/data-and-backend/state-mgmt/intro) no flutter.dev.



![Share on Google+](https://www.gstatic.com/images/branding/google_plus/2x/ic_w_post_gplus_black_24dp.png)

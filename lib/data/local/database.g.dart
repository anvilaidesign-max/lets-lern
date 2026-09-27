// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $TopicsTable extends Topics with TableInfo<$TopicsTable, TopicRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TopicsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _codeMeta = const VerificationMeta('code');
  @override
  late final GeneratedColumn<String> code = GeneratedColumn<String>(
    'code',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _iconMeta = const VerificationMeta('icon');
  @override
  late final GeneratedColumn<String> icon = GeneratedColumn<String>(
    'icon',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sortOrderMeta = const VerificationMeta(
    'sortOrder',
  );
  @override
  late final GeneratedColumn<int> sortOrder = GeneratedColumn<int>(
    'sort_order',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [code, name, icon, sortOrder];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'topics';
  @override
  VerificationContext validateIntegrity(
    Insertable<TopicRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('code')) {
      context.handle(
        _codeMeta,
        code.isAcceptableOrUnknown(data['code']!, _codeMeta),
      );
    } else if (isInserting) {
      context.missing(_codeMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('icon')) {
      context.handle(
        _iconMeta,
        icon.isAcceptableOrUnknown(data['icon']!, _iconMeta),
      );
    } else if (isInserting) {
      context.missing(_iconMeta);
    }
    if (data.containsKey('sort_order')) {
      context.handle(
        _sortOrderMeta,
        sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta),
      );
    } else if (isInserting) {
      context.missing(_sortOrderMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {code};
  @override
  TopicRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TopicRow(
      code: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}code'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      icon: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}icon'],
      )!,
      sortOrder: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sort_order'],
      )!,
    );
  }

  @override
  $TopicsTable createAlias(String alias) {
    return $TopicsTable(attachedDatabase, alias);
  }
}

class TopicRow extends DataClass implements Insertable<TopicRow> {
  final String code;
  final String name;
  final String icon;
  final int sortOrder;
  const TopicRow({
    required this.code,
    required this.name,
    required this.icon,
    required this.sortOrder,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['code'] = Variable<String>(code);
    map['name'] = Variable<String>(name);
    map['icon'] = Variable<String>(icon);
    map['sort_order'] = Variable<int>(sortOrder);
    return map;
  }

  TopicsCompanion toCompanion(bool nullToAbsent) {
    return TopicsCompanion(
      code: Value(code),
      name: Value(name),
      icon: Value(icon),
      sortOrder: Value(sortOrder),
    );
  }

  factory TopicRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TopicRow(
      code: serializer.fromJson<String>(json['code']),
      name: serializer.fromJson<String>(json['name']),
      icon: serializer.fromJson<String>(json['icon']),
      sortOrder: serializer.fromJson<int>(json['sortOrder']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'code': serializer.toJson<String>(code),
      'name': serializer.toJson<String>(name),
      'icon': serializer.toJson<String>(icon),
      'sortOrder': serializer.toJson<int>(sortOrder),
    };
  }

  TopicRow copyWith({
    String? code,
    String? name,
    String? icon,
    int? sortOrder,
  }) => TopicRow(
    code: code ?? this.code,
    name: name ?? this.name,
    icon: icon ?? this.icon,
    sortOrder: sortOrder ?? this.sortOrder,
  );
  TopicRow copyWithCompanion(TopicsCompanion data) {
    return TopicRow(
      code: data.code.present ? data.code.value : this.code,
      name: data.name.present ? data.name.value : this.name,
      icon: data.icon.present ? data.icon.value : this.icon,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TopicRow(')
          ..write('code: $code, ')
          ..write('name: $name, ')
          ..write('icon: $icon, ')
          ..write('sortOrder: $sortOrder')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(code, name, icon, sortOrder);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TopicRow &&
          other.code == this.code &&
          other.name == this.name &&
          other.icon == this.icon &&
          other.sortOrder == this.sortOrder);
}

class TopicsCompanion extends UpdateCompanion<TopicRow> {
  final Value<String> code;
  final Value<String> name;
  final Value<String> icon;
  final Value<int> sortOrder;
  final Value<int> rowid;
  const TopicsCompanion({
    this.code = const Value.absent(),
    this.name = const Value.absent(),
    this.icon = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TopicsCompanion.insert({
    required String code,
    required String name,
    required String icon,
    required int sortOrder,
    this.rowid = const Value.absent(),
  }) : code = Value(code),
       name = Value(name),
       icon = Value(icon),
       sortOrder = Value(sortOrder);
  static Insertable<TopicRow> custom({
    Expression<String>? code,
    Expression<String>? name,
    Expression<String>? icon,
    Expression<int>? sortOrder,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (code != null) 'code': code,
      if (name != null) 'name': name,
      if (icon != null) 'icon': icon,
      if (sortOrder != null) 'sort_order': sortOrder,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TopicsCompanion copyWith({
    Value<String>? code,
    Value<String>? name,
    Value<String>? icon,
    Value<int>? sortOrder,
    Value<int>? rowid,
  }) {
    return TopicsCompanion(
      code: code ?? this.code,
      name: name ?? this.name,
      icon: icon ?? this.icon,
      sortOrder: sortOrder ?? this.sortOrder,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (code.present) {
      map['code'] = Variable<String>(code.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (icon.present) {
      map['icon'] = Variable<String>(icon.value);
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TopicsCompanion(')
          ..write('code: $code, ')
          ..write('name: $name, ')
          ..write('icon: $icon, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ContentItemsTable extends ContentItems
    with TableInfo<$ContentItemsTable, ContentItemRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ContentItemsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _topicCodeMeta = const VerificationMeta(
    'topicCode',
  );
  @override
  late final GeneratedColumn<String> topicCode = GeneratedColumn<String>(
    'topic_code',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
    'type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _bodyMeta = const VerificationMeta('body');
  @override
  late final GeneratedColumn<String> body = GeneratedColumn<String>(
    'body',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _statementMeta = const VerificationMeta(
    'statement',
  );
  @override
  late final GeneratedColumn<String> statement = GeneratedColumn<String>(
    'statement',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isTrueMeta = const VerificationMeta('isTrue');
  @override
  late final GeneratedColumn<bool> isTrue = GeneratedColumn<bool>(
    'is_true',
    aliasedName,
    true,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_true" IN (0, 1))',
    ),
  );
  static const VerificationMeta _correctAnswerMeta = const VerificationMeta(
    'correctAnswer',
  );
  @override
  late final GeneratedColumn<String> correctAnswer = GeneratedColumn<String>(
    'correct_answer',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _explanationMeta = const VerificationMeta(
    'explanation',
  );
  @override
  late final GeneratedColumn<String> explanation = GeneratedColumn<String>(
    'explanation',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _termMeta = const VerificationMeta('term');
  @override
  late final GeneratedColumn<String> term = GeneratedColumn<String>(
    'term',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _translationMeta = const VerificationMeta(
    'translation',
  );
  @override
  late final GeneratedColumn<String> translation = GeneratedColumn<String>(
    'translation',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _exampleSentenceMeta = const VerificationMeta(
    'exampleSentence',
  );
  @override
  late final GeneratedColumn<String> exampleSentence = GeneratedColumn<String>(
    'example_sentence',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _difficultyMeta = const VerificationMeta(
    'difficulty',
  );
  @override
  late final GeneratedColumn<int> difficulty = GeneratedColumn<int>(
    'difficulty',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _sourceNameMeta = const VerificationMeta(
    'sourceName',
  );
  @override
  late final GeneratedColumn<String> sourceName = GeneratedColumn<String>(
    'source_name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _sourceUrlMeta = const VerificationMeta(
    'sourceUrl',
  );
  @override
  late final GeneratedColumn<String> sourceUrl = GeneratedColumn<String>(
    'source_url',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _verifiedMeta = const VerificationMeta(
    'verified',
  );
  @override
  late final GeneratedColumn<bool> verified = GeneratedColumn<bool>(
    'verified',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("verified" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _inOfflinePackMeta = const VerificationMeta(
    'inOfflinePack',
  );
  @override
  late final GeneratedColumn<bool> inOfflinePack = GeneratedColumn<bool>(
    'in_offline_pack',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("in_offline_pack" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _isActiveMeta = const VerificationMeta(
    'isActive',
  );
  @override
  late final GeneratedColumn<bool> isActive = GeneratedColumn<bool>(
    'is_active',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_active" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    topicCode,
    type,
    title,
    body,
    statement,
    isTrue,
    correctAnswer,
    explanation,
    term,
    translation,
    exampleSentence,
    difficulty,
    sourceName,
    sourceUrl,
    verified,
    inOfflinePack,
    isActive,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'content_items';
  @override
  VerificationContext validateIntegrity(
    Insertable<ContentItemRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('topic_code')) {
      context.handle(
        _topicCodeMeta,
        topicCode.isAcceptableOrUnknown(data['topic_code']!, _topicCodeMeta),
      );
    } else if (isInserting) {
      context.missing(_topicCodeMeta);
    }
    if (data.containsKey('type')) {
      context.handle(
        _typeMeta,
        type.isAcceptableOrUnknown(data['type']!, _typeMeta),
      );
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('body')) {
      context.handle(
        _bodyMeta,
        body.isAcceptableOrUnknown(data['body']!, _bodyMeta),
      );
    } else if (isInserting) {
      context.missing(_bodyMeta);
    }
    if (data.containsKey('statement')) {
      context.handle(
        _statementMeta,
        statement.isAcceptableOrUnknown(data['statement']!, _statementMeta),
      );
    }
    if (data.containsKey('is_true')) {
      context.handle(
        _isTrueMeta,
        isTrue.isAcceptableOrUnknown(data['is_true']!, _isTrueMeta),
      );
    }
    if (data.containsKey('correct_answer')) {
      context.handle(
        _correctAnswerMeta,
        correctAnswer.isAcceptableOrUnknown(
          data['correct_answer']!,
          _correctAnswerMeta,
        ),
      );
    }
    if (data.containsKey('explanation')) {
      context.handle(
        _explanationMeta,
        explanation.isAcceptableOrUnknown(
          data['explanation']!,
          _explanationMeta,
        ),
      );
    }
    if (data.containsKey('term')) {
      context.handle(
        _termMeta,
        term.isAcceptableOrUnknown(data['term']!, _termMeta),
      );
    }
    if (data.containsKey('translation')) {
      context.handle(
        _translationMeta,
        translation.isAcceptableOrUnknown(
          data['translation']!,
          _translationMeta,
        ),
      );
    }
    if (data.containsKey('example_sentence')) {
      context.handle(
        _exampleSentenceMeta,
        exampleSentence.isAcceptableOrUnknown(
          data['example_sentence']!,
          _exampleSentenceMeta,
        ),
      );
    }
    if (data.containsKey('difficulty')) {
      context.handle(
        _difficultyMeta,
        difficulty.isAcceptableOrUnknown(data['difficulty']!, _difficultyMeta),
      );
    }
    if (data.containsKey('source_name')) {
      context.handle(
        _sourceNameMeta,
        sourceName.isAcceptableOrUnknown(data['source_name']!, _sourceNameMeta),
      );
    }
    if (data.containsKey('source_url')) {
      context.handle(
        _sourceUrlMeta,
        sourceUrl.isAcceptableOrUnknown(data['source_url']!, _sourceUrlMeta),
      );
    }
    if (data.containsKey('verified')) {
      context.handle(
        _verifiedMeta,
        verified.isAcceptableOrUnknown(data['verified']!, _verifiedMeta),
      );
    }
    if (data.containsKey('in_offline_pack')) {
      context.handle(
        _inOfflinePackMeta,
        inOfflinePack.isAcceptableOrUnknown(
          data['in_offline_pack']!,
          _inOfflinePackMeta,
        ),
      );
    }
    if (data.containsKey('is_active')) {
      context.handle(
        _isActiveMeta,
        isActive.isAcceptableOrUnknown(data['is_active']!, _isActiveMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ContentItemRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ContentItemRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      topicCode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}topic_code'],
      )!,
      type: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}type'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      body: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}body'],
      )!,
      statement: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}statement'],
      ),
      isTrue: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_true'],
      ),
      correctAnswer: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}correct_answer'],
      ),
      explanation: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}explanation'],
      ),
      term: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}term'],
      ),
      translation: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}translation'],
      ),
      exampleSentence: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}example_sentence'],
      ),
      difficulty: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}difficulty'],
      )!,
      sourceName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source_name'],
      ),
      sourceUrl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source_url'],
      ),
      verified: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}verified'],
      )!,
      inOfflinePack: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}in_offline_pack'],
      )!,
      isActive: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_active'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      ),
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      ),
    );
  }

  @override
  $ContentItemsTable createAlias(String alias) {
    return $ContentItemsTable(attachedDatabase, alias);
  }
}

class ContentItemRow extends DataClass implements Insertable<ContentItemRow> {
  final String id;
  final String topicCode;
  final String type;
  final String title;
  final String body;
  final String? statement;
  final bool? isTrue;
  final String? correctAnswer;
  final String? explanation;
  final String? term;
  final String? translation;
  final String? exampleSentence;
  final int difficulty;
  final String? sourceName;
  final String? sourceUrl;
  final bool verified;
  final bool inOfflinePack;
  final bool isActive;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  const ContentItemRow({
    required this.id,
    required this.topicCode,
    required this.type,
    required this.title,
    required this.body,
    this.statement,
    this.isTrue,
    this.correctAnswer,
    this.explanation,
    this.term,
    this.translation,
    this.exampleSentence,
    required this.difficulty,
    this.sourceName,
    this.sourceUrl,
    required this.verified,
    required this.inOfflinePack,
    required this.isActive,
    this.createdAt,
    this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['topic_code'] = Variable<String>(topicCode);
    map['type'] = Variable<String>(type);
    map['title'] = Variable<String>(title);
    map['body'] = Variable<String>(body);
    if (!nullToAbsent || statement != null) {
      map['statement'] = Variable<String>(statement);
    }
    if (!nullToAbsent || isTrue != null) {
      map['is_true'] = Variable<bool>(isTrue);
    }
    if (!nullToAbsent || correctAnswer != null) {
      map['correct_answer'] = Variable<String>(correctAnswer);
    }
    if (!nullToAbsent || explanation != null) {
      map['explanation'] = Variable<String>(explanation);
    }
    if (!nullToAbsent || term != null) {
      map['term'] = Variable<String>(term);
    }
    if (!nullToAbsent || translation != null) {
      map['translation'] = Variable<String>(translation);
    }
    if (!nullToAbsent || exampleSentence != null) {
      map['example_sentence'] = Variable<String>(exampleSentence);
    }
    map['difficulty'] = Variable<int>(difficulty);
    if (!nullToAbsent || sourceName != null) {
      map['source_name'] = Variable<String>(sourceName);
    }
    if (!nullToAbsent || sourceUrl != null) {
      map['source_url'] = Variable<String>(sourceUrl);
    }
    map['verified'] = Variable<bool>(verified);
    map['in_offline_pack'] = Variable<bool>(inOfflinePack);
    map['is_active'] = Variable<bool>(isActive);
    if (!nullToAbsent || createdAt != null) {
      map['created_at'] = Variable<DateTime>(createdAt);
    }
    if (!nullToAbsent || updatedAt != null) {
      map['updated_at'] = Variable<DateTime>(updatedAt);
    }
    return map;
  }

  ContentItemsCompanion toCompanion(bool nullToAbsent) {
    return ContentItemsCompanion(
      id: Value(id),
      topicCode: Value(topicCode),
      type: Value(type),
      title: Value(title),
      body: Value(body),
      statement: statement == null && nullToAbsent
          ? const Value.absent()
          : Value(statement),
      isTrue: isTrue == null && nullToAbsent
          ? const Value.absent()
          : Value(isTrue),
      correctAnswer: correctAnswer == null && nullToAbsent
          ? const Value.absent()
          : Value(correctAnswer),
      explanation: explanation == null && nullToAbsent
          ? const Value.absent()
          : Value(explanation),
      term: term == null && nullToAbsent ? const Value.absent() : Value(term),
      translation: translation == null && nullToAbsent
          ? const Value.absent()
          : Value(translation),
      exampleSentence: exampleSentence == null && nullToAbsent
          ? const Value.absent()
          : Value(exampleSentence),
      difficulty: Value(difficulty),
      sourceName: sourceName == null && nullToAbsent
          ? const Value.absent()
          : Value(sourceName),
      sourceUrl: sourceUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(sourceUrl),
      verified: Value(verified),
      inOfflinePack: Value(inOfflinePack),
      isActive: Value(isActive),
      createdAt: createdAt == null && nullToAbsent
          ? const Value.absent()
          : Value(createdAt),
      updatedAt: updatedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(updatedAt),
    );
  }

  factory ContentItemRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ContentItemRow(
      id: serializer.fromJson<String>(json['id']),
      topicCode: serializer.fromJson<String>(json['topicCode']),
      type: serializer.fromJson<String>(json['type']),
      title: serializer.fromJson<String>(json['title']),
      body: serializer.fromJson<String>(json['body']),
      statement: serializer.fromJson<String?>(json['statement']),
      isTrue: serializer.fromJson<bool?>(json['isTrue']),
      correctAnswer: serializer.fromJson<String?>(json['correctAnswer']),
      explanation: serializer.fromJson<String?>(json['explanation']),
      term: serializer.fromJson<String?>(json['term']),
      translation: serializer.fromJson<String?>(json['translation']),
      exampleSentence: serializer.fromJson<String?>(json['exampleSentence']),
      difficulty: serializer.fromJson<int>(json['difficulty']),
      sourceName: serializer.fromJson<String?>(json['sourceName']),
      sourceUrl: serializer.fromJson<String?>(json['sourceUrl']),
      verified: serializer.fromJson<bool>(json['verified']),
      inOfflinePack: serializer.fromJson<bool>(json['inOfflinePack']),
      isActive: serializer.fromJson<bool>(json['isActive']),
      createdAt: serializer.fromJson<DateTime?>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime?>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'topicCode': serializer.toJson<String>(topicCode),
      'type': serializer.toJson<String>(type),
      'title': serializer.toJson<String>(title),
      'body': serializer.toJson<String>(body),
      'statement': serializer.toJson<String?>(statement),
      'isTrue': serializer.toJson<bool?>(isTrue),
      'correctAnswer': serializer.toJson<String?>(correctAnswer),
      'explanation': serializer.toJson<String?>(explanation),
      'term': serializer.toJson<String?>(term),
      'translation': serializer.toJson<String?>(translation),
      'exampleSentence': serializer.toJson<String?>(exampleSentence),
      'difficulty': serializer.toJson<int>(difficulty),
      'sourceName': serializer.toJson<String?>(sourceName),
      'sourceUrl': serializer.toJson<String?>(sourceUrl),
      'verified': serializer.toJson<bool>(verified),
      'inOfflinePack': serializer.toJson<bool>(inOfflinePack),
      'isActive': serializer.toJson<bool>(isActive),
      'createdAt': serializer.toJson<DateTime?>(createdAt),
      'updatedAt': serializer.toJson<DateTime?>(updatedAt),
    };
  }

  ContentItemRow copyWith({
    String? id,
    String? topicCode,
    String? type,
    String? title,
    String? body,
    Value<String?> statement = const Value.absent(),
    Value<bool?> isTrue = const Value.absent(),
    Value<String?> correctAnswer = const Value.absent(),
    Value<String?> explanation = const Value.absent(),
    Value<String?> term = const Value.absent(),
    Value<String?> translation = const Value.absent(),
    Value<String?> exampleSentence = const Value.absent(),
    int? difficulty,
    Value<String?> sourceName = const Value.absent(),
    Value<String?> sourceUrl = const Value.absent(),
    bool? verified,
    bool? inOfflinePack,
    bool? isActive,
    Value<DateTime?> createdAt = const Value.absent(),
    Value<DateTime?> updatedAt = const Value.absent(),
  }) => ContentItemRow(
    id: id ?? this.id,
    topicCode: topicCode ?? this.topicCode,
    type: type ?? this.type,
    title: title ?? this.title,
    body: body ?? this.body,
    statement: statement.present ? statement.value : this.statement,
    isTrue: isTrue.present ? isTrue.value : this.isTrue,
    correctAnswer: correctAnswer.present
        ? correctAnswer.value
        : this.correctAnswer,
    explanation: explanation.present ? explanation.value : this.explanation,
    term: term.present ? term.value : this.term,
    translation: translation.present ? translation.value : this.translation,
    exampleSentence: exampleSentence.present
        ? exampleSentence.value
        : this.exampleSentence,
    difficulty: difficulty ?? this.difficulty,
    sourceName: sourceName.present ? sourceName.value : this.sourceName,
    sourceUrl: sourceUrl.present ? sourceUrl.value : this.sourceUrl,
    verified: verified ?? this.verified,
    inOfflinePack: inOfflinePack ?? this.inOfflinePack,
    isActive: isActive ?? this.isActive,
    createdAt: createdAt.present ? createdAt.value : this.createdAt,
    updatedAt: updatedAt.present ? updatedAt.value : this.updatedAt,
  );
  ContentItemRow copyWithCompanion(ContentItemsCompanion data) {
    return ContentItemRow(
      id: data.id.present ? data.id.value : this.id,
      topicCode: data.topicCode.present ? data.topicCode.value : this.topicCode,
      type: data.type.present ? data.type.value : this.type,
      title: data.title.present ? data.title.value : this.title,
      body: data.body.present ? data.body.value : this.body,
      statement: data.statement.present ? data.statement.value : this.statement,
      isTrue: data.isTrue.present ? data.isTrue.value : this.isTrue,
      correctAnswer: data.correctAnswer.present
          ? data.correctAnswer.value
          : this.correctAnswer,
      explanation: data.explanation.present
          ? data.explanation.value
          : this.explanation,
      term: data.term.present ? data.term.value : this.term,
      translation: data.translation.present
          ? data.translation.value
          : this.translation,
      exampleSentence: data.exampleSentence.present
          ? data.exampleSentence.value
          : this.exampleSentence,
      difficulty: data.difficulty.present
          ? data.difficulty.value
          : this.difficulty,
      sourceName: data.sourceName.present
          ? data.sourceName.value
          : this.sourceName,
      sourceUrl: data.sourceUrl.present ? data.sourceUrl.value : this.sourceUrl,
      verified: data.verified.present ? data.verified.value : this.verified,
      inOfflinePack: data.inOfflinePack.present
          ? data.inOfflinePack.value
          : this.inOfflinePack,
      isActive: data.isActive.present ? data.isActive.value : this.isActive,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ContentItemRow(')
          ..write('id: $id, ')
          ..write('topicCode: $topicCode, ')
          ..write('type: $type, ')
          ..write('title: $title, ')
          ..write('body: $body, ')
          ..write('statement: $statement, ')
          ..write('isTrue: $isTrue, ')
          ..write('correctAnswer: $correctAnswer, ')
          ..write('explanation: $explanation, ')
          ..write('term: $term, ')
          ..write('translation: $translation, ')
          ..write('exampleSentence: $exampleSentence, ')
          ..write('difficulty: $difficulty, ')
          ..write('sourceName: $sourceName, ')
          ..write('sourceUrl: $sourceUrl, ')
          ..write('verified: $verified, ')
          ..write('inOfflinePack: $inOfflinePack, ')
          ..write('isActive: $isActive, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    topicCode,
    type,
    title,
    body,
    statement,
    isTrue,
    correctAnswer,
    explanation,
    term,
    translation,
    exampleSentence,
    difficulty,
    sourceName,
    sourceUrl,
    verified,
    inOfflinePack,
    isActive,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ContentItemRow &&
          other.id == this.id &&
          other.topicCode == this.topicCode &&
          other.type == this.type &&
          other.title == this.title &&
          other.body == this.body &&
          other.statement == this.statement &&
          other.isTrue == this.isTrue &&
          other.correctAnswer == this.correctAnswer &&
          other.explanation == this.explanation &&
          other.term == this.term &&
          other.translation == this.translation &&
          other.exampleSentence == this.exampleSentence &&
          other.difficulty == this.difficulty &&
          other.sourceName == this.sourceName &&
          other.sourceUrl == this.sourceUrl &&
          other.verified == this.verified &&
          other.inOfflinePack == this.inOfflinePack &&
          other.isActive == this.isActive &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class ContentItemsCompanion extends UpdateCompanion<ContentItemRow> {
  final Value<String> id;
  final Value<String> topicCode;
  final Value<String> type;
  final Value<String> title;
  final Value<String> body;
  final Value<String?> statement;
  final Value<bool?> isTrue;
  final Value<String?> correctAnswer;
  final Value<String?> explanation;
  final Value<String?> term;
  final Value<String?> translation;
  final Value<String?> exampleSentence;
  final Value<int> difficulty;
  final Value<String?> sourceName;
  final Value<String?> sourceUrl;
  final Value<bool> verified;
  final Value<bool> inOfflinePack;
  final Value<bool> isActive;
  final Value<DateTime?> createdAt;
  final Value<DateTime?> updatedAt;
  final Value<int> rowid;
  const ContentItemsCompanion({
    this.id = const Value.absent(),
    this.topicCode = const Value.absent(),
    this.type = const Value.absent(),
    this.title = const Value.absent(),
    this.body = const Value.absent(),
    this.statement = const Value.absent(),
    this.isTrue = const Value.absent(),
    this.correctAnswer = const Value.absent(),
    this.explanation = const Value.absent(),
    this.term = const Value.absent(),
    this.translation = const Value.absent(),
    this.exampleSentence = const Value.absent(),
    this.difficulty = const Value.absent(),
    this.sourceName = const Value.absent(),
    this.sourceUrl = const Value.absent(),
    this.verified = const Value.absent(),
    this.inOfflinePack = const Value.absent(),
    this.isActive = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ContentItemsCompanion.insert({
    required String id,
    required String topicCode,
    required String type,
    required String title,
    required String body,
    this.statement = const Value.absent(),
    this.isTrue = const Value.absent(),
    this.correctAnswer = const Value.absent(),
    this.explanation = const Value.absent(),
    this.term = const Value.absent(),
    this.translation = const Value.absent(),
    this.exampleSentence = const Value.absent(),
    this.difficulty = const Value.absent(),
    this.sourceName = const Value.absent(),
    this.sourceUrl = const Value.absent(),
    this.verified = const Value.absent(),
    this.inOfflinePack = const Value.absent(),
    this.isActive = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       topicCode = Value(topicCode),
       type = Value(type),
       title = Value(title),
       body = Value(body);
  static Insertable<ContentItemRow> custom({
    Expression<String>? id,
    Expression<String>? topicCode,
    Expression<String>? type,
    Expression<String>? title,
    Expression<String>? body,
    Expression<String>? statement,
    Expression<bool>? isTrue,
    Expression<String>? correctAnswer,
    Expression<String>? explanation,
    Expression<String>? term,
    Expression<String>? translation,
    Expression<String>? exampleSentence,
    Expression<int>? difficulty,
    Expression<String>? sourceName,
    Expression<String>? sourceUrl,
    Expression<bool>? verified,
    Expression<bool>? inOfflinePack,
    Expression<bool>? isActive,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (topicCode != null) 'topic_code': topicCode,
      if (type != null) 'type': type,
      if (title != null) 'title': title,
      if (body != null) 'body': body,
      if (statement != null) 'statement': statement,
      if (isTrue != null) 'is_true': isTrue,
      if (correctAnswer != null) 'correct_answer': correctAnswer,
      if (explanation != null) 'explanation': explanation,
      if (term != null) 'term': term,
      if (translation != null) 'translation': translation,
      if (exampleSentence != null) 'example_sentence': exampleSentence,
      if (difficulty != null) 'difficulty': difficulty,
      if (sourceName != null) 'source_name': sourceName,
      if (sourceUrl != null) 'source_url': sourceUrl,
      if (verified != null) 'verified': verified,
      if (inOfflinePack != null) 'in_offline_pack': inOfflinePack,
      if (isActive != null) 'is_active': isActive,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ContentItemsCompanion copyWith({
    Value<String>? id,
    Value<String>? topicCode,
    Value<String>? type,
    Value<String>? title,
    Value<String>? body,
    Value<String?>? statement,
    Value<bool?>? isTrue,
    Value<String?>? correctAnswer,
    Value<String?>? explanation,
    Value<String?>? term,
    Value<String?>? translation,
    Value<String?>? exampleSentence,
    Value<int>? difficulty,
    Value<String?>? sourceName,
    Value<String?>? sourceUrl,
    Value<bool>? verified,
    Value<bool>? inOfflinePack,
    Value<bool>? isActive,
    Value<DateTime?>? createdAt,
    Value<DateTime?>? updatedAt,
    Value<int>? rowid,
  }) {
    return ContentItemsCompanion(
      id: id ?? this.id,
      topicCode: topicCode ?? this.topicCode,
      type: type ?? this.type,
      title: title ?? this.title,
      body: body ?? this.body,
      statement: statement ?? this.statement,
      isTrue: isTrue ?? this.isTrue,
      correctAnswer: correctAnswer ?? this.correctAnswer,
      explanation: explanation ?? this.explanation,
      term: term ?? this.term,
      translation: translation ?? this.translation,
      exampleSentence: exampleSentence ?? this.exampleSentence,
      difficulty: difficulty ?? this.difficulty,
      sourceName: sourceName ?? this.sourceName,
      sourceUrl: sourceUrl ?? this.sourceUrl,
      verified: verified ?? this.verified,
      inOfflinePack: inOfflinePack ?? this.inOfflinePack,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (topicCode.present) {
      map['topic_code'] = Variable<String>(topicCode.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (body.present) {
      map['body'] = Variable<String>(body.value);
    }
    if (statement.present) {
      map['statement'] = Variable<String>(statement.value);
    }
    if (isTrue.present) {
      map['is_true'] = Variable<bool>(isTrue.value);
    }
    if (correctAnswer.present) {
      map['correct_answer'] = Variable<String>(correctAnswer.value);
    }
    if (explanation.present) {
      map['explanation'] = Variable<String>(explanation.value);
    }
    if (term.present) {
      map['term'] = Variable<String>(term.value);
    }
    if (translation.present) {
      map['translation'] = Variable<String>(translation.value);
    }
    if (exampleSentence.present) {
      map['example_sentence'] = Variable<String>(exampleSentence.value);
    }
    if (difficulty.present) {
      map['difficulty'] = Variable<int>(difficulty.value);
    }
    if (sourceName.present) {
      map['source_name'] = Variable<String>(sourceName.value);
    }
    if (sourceUrl.present) {
      map['source_url'] = Variable<String>(sourceUrl.value);
    }
    if (verified.present) {
      map['verified'] = Variable<bool>(verified.value);
    }
    if (inOfflinePack.present) {
      map['in_offline_pack'] = Variable<bool>(inOfflinePack.value);
    }
    if (isActive.present) {
      map['is_active'] = Variable<bool>(isActive.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ContentItemsCompanion(')
          ..write('id: $id, ')
          ..write('topicCode: $topicCode, ')
          ..write('type: $type, ')
          ..write('title: $title, ')
          ..write('body: $body, ')
          ..write('statement: $statement, ')
          ..write('isTrue: $isTrue, ')
          ..write('correctAnswer: $correctAnswer, ')
          ..write('explanation: $explanation, ')
          ..write('term: $term, ')
          ..write('translation: $translation, ')
          ..write('exampleSentence: $exampleSentence, ')
          ..write('difficulty: $difficulty, ')
          ..write('sourceName: $sourceName, ')
          ..write('sourceUrl: $sourceUrl, ')
          ..write('verified: $verified, ')
          ..write('inOfflinePack: $inOfflinePack, ')
          ..write('isActive: $isActive, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $EssayPromptsTable extends EssayPrompts
    with TableInfo<$EssayPromptsTable, EssayPromptRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $EssayPromptsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _topicCodeMeta = const VerificationMeta(
    'topicCode',
  );
  @override
  late final GeneratedColumn<String> topicCode = GeneratedColumn<String>(
    'topic_code',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _promptMeta = const VerificationMeta('prompt');
  @override
  late final GeneratedColumn<String> prompt = GeneratedColumn<String>(
    'prompt',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, topicCode, prompt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'essay_prompts';
  @override
  VerificationContext validateIntegrity(
    Insertable<EssayPromptRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('topic_code')) {
      context.handle(
        _topicCodeMeta,
        topicCode.isAcceptableOrUnknown(data['topic_code']!, _topicCodeMeta),
      );
    }
    if (data.containsKey('prompt')) {
      context.handle(
        _promptMeta,
        prompt.isAcceptableOrUnknown(data['prompt']!, _promptMeta),
      );
    } else if (isInserting) {
      context.missing(_promptMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  EssayPromptRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return EssayPromptRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      topicCode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}topic_code'],
      ),
      prompt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}prompt'],
      )!,
    );
  }

  @override
  $EssayPromptsTable createAlias(String alias) {
    return $EssayPromptsTable(attachedDatabase, alias);
  }
}

class EssayPromptRow extends DataClass implements Insertable<EssayPromptRow> {
  final String id;
  final String? topicCode;
  final String prompt;
  const EssayPromptRow({
    required this.id,
    this.topicCode,
    required this.prompt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    if (!nullToAbsent || topicCode != null) {
      map['topic_code'] = Variable<String>(topicCode);
    }
    map['prompt'] = Variable<String>(prompt);
    return map;
  }

  EssayPromptsCompanion toCompanion(bool nullToAbsent) {
    return EssayPromptsCompanion(
      id: Value(id),
      topicCode: topicCode == null && nullToAbsent
          ? const Value.absent()
          : Value(topicCode),
      prompt: Value(prompt),
    );
  }

  factory EssayPromptRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return EssayPromptRow(
      id: serializer.fromJson<String>(json['id']),
      topicCode: serializer.fromJson<String?>(json['topicCode']),
      prompt: serializer.fromJson<String>(json['prompt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'topicCode': serializer.toJson<String?>(topicCode),
      'prompt': serializer.toJson<String>(prompt),
    };
  }

  EssayPromptRow copyWith({
    String? id,
    Value<String?> topicCode = const Value.absent(),
    String? prompt,
  }) => EssayPromptRow(
    id: id ?? this.id,
    topicCode: topicCode.present ? topicCode.value : this.topicCode,
    prompt: prompt ?? this.prompt,
  );
  EssayPromptRow copyWithCompanion(EssayPromptsCompanion data) {
    return EssayPromptRow(
      id: data.id.present ? data.id.value : this.id,
      topicCode: data.topicCode.present ? data.topicCode.value : this.topicCode,
      prompt: data.prompt.present ? data.prompt.value : this.prompt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('EssayPromptRow(')
          ..write('id: $id, ')
          ..write('topicCode: $topicCode, ')
          ..write('prompt: $prompt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, topicCode, prompt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is EssayPromptRow &&
          other.id == this.id &&
          other.topicCode == this.topicCode &&
          other.prompt == this.prompt);
}

class EssayPromptsCompanion extends UpdateCompanion<EssayPromptRow> {
  final Value<String> id;
  final Value<String?> topicCode;
  final Value<String> prompt;
  final Value<int> rowid;
  const EssayPromptsCompanion({
    this.id = const Value.absent(),
    this.topicCode = const Value.absent(),
    this.prompt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  EssayPromptsCompanion.insert({
    required String id,
    this.topicCode = const Value.absent(),
    required String prompt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       prompt = Value(prompt);
  static Insertable<EssayPromptRow> custom({
    Expression<String>? id,
    Expression<String>? topicCode,
    Expression<String>? prompt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (topicCode != null) 'topic_code': topicCode,
      if (prompt != null) 'prompt': prompt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  EssayPromptsCompanion copyWith({
    Value<String>? id,
    Value<String?>? topicCode,
    Value<String>? prompt,
    Value<int>? rowid,
  }) {
    return EssayPromptsCompanion(
      id: id ?? this.id,
      topicCode: topicCode ?? this.topicCode,
      prompt: prompt ?? this.prompt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (topicCode.present) {
      map['topic_code'] = Variable<String>(topicCode.value);
    }
    if (prompt.present) {
      map['prompt'] = Variable<String>(prompt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('EssayPromptsCompanion(')
          ..write('id: $id, ')
          ..write('topicCode: $topicCode, ')
          ..write('prompt: $prompt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $UserProgressTable extends UserProgress
    with TableInfo<$UserProgressTable, ProgressRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $UserProgressTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _itemIdMeta = const VerificationMeta('itemId');
  @override
  late final GeneratedColumn<String> itemId = GeneratedColumn<String>(
    'item_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _seenCountMeta = const VerificationMeta(
    'seenCount',
  );
  @override
  late final GeneratedColumn<int> seenCount = GeneratedColumn<int>(
    'seen_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _answeredCorrectMeta = const VerificationMeta(
    'answeredCorrect',
  );
  @override
  late final GeneratedColumn<int> answeredCorrect = GeneratedColumn<int>(
    'answered_correct',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _answeredWrongMeta = const VerificationMeta(
    'answeredWrong',
  );
  @override
  late final GeneratedColumn<int> answeredWrong = GeneratedColumn<int>(
    'answered_wrong',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _lastAnswerCorrectMeta = const VerificationMeta(
    'lastAnswerCorrect',
  );
  @override
  late final GeneratedColumn<bool> lastAnswerCorrect = GeneratedColumn<bool>(
    'last_answer_correct',
    aliasedName,
    true,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("last_answer_correct" IN (0, 1))',
    ),
  );
  static const VerificationMeta _lastSeenAtMeta = const VerificationMeta(
    'lastSeenAt',
  );
  @override
  late final GeneratedColumn<DateTime> lastSeenAt = GeneratedColumn<DateTime>(
    'last_seen_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _savedMeta = const VerificationMeta('saved');
  @override
  late final GeneratedColumn<bool> saved = GeneratedColumn<bool>(
    'saved',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("saved" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _savedUpdatedAtMeta = const VerificationMeta(
    'savedUpdatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> savedUpdatedAt =
      GeneratedColumn<DateTime>(
        'saved_updated_at',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _reportedMeta = const VerificationMeta(
    'reported',
  );
  @override
  late final GeneratedColumn<bool> reported = GeneratedColumn<bool>(
    'reported',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("reported" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    itemId,
    seenCount,
    answeredCorrect,
    answeredWrong,
    lastAnswerCorrect,
    lastSeenAt,
    saved,
    savedUpdatedAt,
    reported,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'user_progress';
  @override
  VerificationContext validateIntegrity(
    Insertable<ProgressRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('item_id')) {
      context.handle(
        _itemIdMeta,
        itemId.isAcceptableOrUnknown(data['item_id']!, _itemIdMeta),
      );
    } else if (isInserting) {
      context.missing(_itemIdMeta);
    }
    if (data.containsKey('seen_count')) {
      context.handle(
        _seenCountMeta,
        seenCount.isAcceptableOrUnknown(data['seen_count']!, _seenCountMeta),
      );
    }
    if (data.containsKey('answered_correct')) {
      context.handle(
        _answeredCorrectMeta,
        answeredCorrect.isAcceptableOrUnknown(
          data['answered_correct']!,
          _answeredCorrectMeta,
        ),
      );
    }
    if (data.containsKey('answered_wrong')) {
      context.handle(
        _answeredWrongMeta,
        answeredWrong.isAcceptableOrUnknown(
          data['answered_wrong']!,
          _answeredWrongMeta,
        ),
      );
    }
    if (data.containsKey('last_answer_correct')) {
      context.handle(
        _lastAnswerCorrectMeta,
        lastAnswerCorrect.isAcceptableOrUnknown(
          data['last_answer_correct']!,
          _lastAnswerCorrectMeta,
        ),
      );
    }
    if (data.containsKey('last_seen_at')) {
      context.handle(
        _lastSeenAtMeta,
        lastSeenAt.isAcceptableOrUnknown(
          data['last_seen_at']!,
          _lastSeenAtMeta,
        ),
      );
    }
    if (data.containsKey('saved')) {
      context.handle(
        _savedMeta,
        saved.isAcceptableOrUnknown(data['saved']!, _savedMeta),
      );
    }
    if (data.containsKey('saved_updated_at')) {
      context.handle(
        _savedUpdatedAtMeta,
        savedUpdatedAt.isAcceptableOrUnknown(
          data['saved_updated_at']!,
          _savedUpdatedAtMeta,
        ),
      );
    }
    if (data.containsKey('reported')) {
      context.handle(
        _reportedMeta,
        reported.isAcceptableOrUnknown(data['reported']!, _reportedMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {itemId};
  @override
  ProgressRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ProgressRow(
      itemId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}item_id'],
      )!,
      seenCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}seen_count'],
      )!,
      answeredCorrect: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}answered_correct'],
      )!,
      answeredWrong: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}answered_wrong'],
      )!,
      lastAnswerCorrect: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}last_answer_correct'],
      ),
      lastSeenAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_seen_at'],
      ),
      saved: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}saved'],
      )!,
      savedUpdatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}saved_updated_at'],
      ),
      reported: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}reported'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      ),
    );
  }

  @override
  $UserProgressTable createAlias(String alias) {
    return $UserProgressTable(attachedDatabase, alias);
  }
}

class ProgressRow extends DataClass implements Insertable<ProgressRow> {
  final String itemId;
  final int seenCount;
  final int answeredCorrect;
  final int answeredWrong;
  final bool? lastAnswerCorrect;
  final DateTime? lastSeenAt;
  final bool saved;
  final DateTime? savedUpdatedAt;
  final bool reported;
  final DateTime? updatedAt;
  const ProgressRow({
    required this.itemId,
    required this.seenCount,
    required this.answeredCorrect,
    required this.answeredWrong,
    this.lastAnswerCorrect,
    this.lastSeenAt,
    required this.saved,
    this.savedUpdatedAt,
    required this.reported,
    this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['item_id'] = Variable<String>(itemId);
    map['seen_count'] = Variable<int>(seenCount);
    map['answered_correct'] = Variable<int>(answeredCorrect);
    map['answered_wrong'] = Variable<int>(answeredWrong);
    if (!nullToAbsent || lastAnswerCorrect != null) {
      map['last_answer_correct'] = Variable<bool>(lastAnswerCorrect);
    }
    if (!nullToAbsent || lastSeenAt != null) {
      map['last_seen_at'] = Variable<DateTime>(lastSeenAt);
    }
    map['saved'] = Variable<bool>(saved);
    if (!nullToAbsent || savedUpdatedAt != null) {
      map['saved_updated_at'] = Variable<DateTime>(savedUpdatedAt);
    }
    map['reported'] = Variable<bool>(reported);
    if (!nullToAbsent || updatedAt != null) {
      map['updated_at'] = Variable<DateTime>(updatedAt);
    }
    return map;
  }

  UserProgressCompanion toCompanion(bool nullToAbsent) {
    return UserProgressCompanion(
      itemId: Value(itemId),
      seenCount: Value(seenCount),
      answeredCorrect: Value(answeredCorrect),
      answeredWrong: Value(answeredWrong),
      lastAnswerCorrect: lastAnswerCorrect == null && nullToAbsent
          ? const Value.absent()
          : Value(lastAnswerCorrect),
      lastSeenAt: lastSeenAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastSeenAt),
      saved: Value(saved),
      savedUpdatedAt: savedUpdatedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(savedUpdatedAt),
      reported: Value(reported),
      updatedAt: updatedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(updatedAt),
    );
  }

  factory ProgressRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ProgressRow(
      itemId: serializer.fromJson<String>(json['itemId']),
      seenCount: serializer.fromJson<int>(json['seenCount']),
      answeredCorrect: serializer.fromJson<int>(json['answeredCorrect']),
      answeredWrong: serializer.fromJson<int>(json['answeredWrong']),
      lastAnswerCorrect: serializer.fromJson<bool?>(json['lastAnswerCorrect']),
      lastSeenAt: serializer.fromJson<DateTime?>(json['lastSeenAt']),
      saved: serializer.fromJson<bool>(json['saved']),
      savedUpdatedAt: serializer.fromJson<DateTime?>(json['savedUpdatedAt']),
      reported: serializer.fromJson<bool>(json['reported']),
      updatedAt: serializer.fromJson<DateTime?>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'itemId': serializer.toJson<String>(itemId),
      'seenCount': serializer.toJson<int>(seenCount),
      'answeredCorrect': serializer.toJson<int>(answeredCorrect),
      'answeredWrong': serializer.toJson<int>(answeredWrong),
      'lastAnswerCorrect': serializer.toJson<bool?>(lastAnswerCorrect),
      'lastSeenAt': serializer.toJson<DateTime?>(lastSeenAt),
      'saved': serializer.toJson<bool>(saved),
      'savedUpdatedAt': serializer.toJson<DateTime?>(savedUpdatedAt),
      'reported': serializer.toJson<bool>(reported),
      'updatedAt': serializer.toJson<DateTime?>(updatedAt),
    };
  }

  ProgressRow copyWith({
    String? itemId,
    int? seenCount,
    int? answeredCorrect,
    int? answeredWrong,
    Value<bool?> lastAnswerCorrect = const Value.absent(),
    Value<DateTime?> lastSeenAt = const Value.absent(),
    bool? saved,
    Value<DateTime?> savedUpdatedAt = const Value.absent(),
    bool? reported,
    Value<DateTime?> updatedAt = const Value.absent(),
  }) => ProgressRow(
    itemId: itemId ?? this.itemId,
    seenCount: seenCount ?? this.seenCount,
    answeredCorrect: answeredCorrect ?? this.answeredCorrect,
    answeredWrong: answeredWrong ?? this.answeredWrong,
    lastAnswerCorrect: lastAnswerCorrect.present
        ? lastAnswerCorrect.value
        : this.lastAnswerCorrect,
    lastSeenAt: lastSeenAt.present ? lastSeenAt.value : this.lastSeenAt,
    saved: saved ?? this.saved,
    savedUpdatedAt: savedUpdatedAt.present
        ? savedUpdatedAt.value
        : this.savedUpdatedAt,
    reported: reported ?? this.reported,
    updatedAt: updatedAt.present ? updatedAt.value : this.updatedAt,
  );
  ProgressRow copyWithCompanion(UserProgressCompanion data) {
    return ProgressRow(
      itemId: data.itemId.present ? data.itemId.value : this.itemId,
      seenCount: data.seenCount.present ? data.seenCount.value : this.seenCount,
      answeredCorrect: data.answeredCorrect.present
          ? data.answeredCorrect.value
          : this.answeredCorrect,
      answeredWrong: data.answeredWrong.present
          ? data.answeredWrong.value
          : this.answeredWrong,
      lastAnswerCorrect: data.lastAnswerCorrect.present
          ? data.lastAnswerCorrect.value
          : this.lastAnswerCorrect,
      lastSeenAt: data.lastSeenAt.present
          ? data.lastSeenAt.value
          : this.lastSeenAt,
      saved: data.saved.present ? data.saved.value : this.saved,
      savedUpdatedAt: data.savedUpdatedAt.present
          ? data.savedUpdatedAt.value
          : this.savedUpdatedAt,
      reported: data.reported.present ? data.reported.value : this.reported,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ProgressRow(')
          ..write('itemId: $itemId, ')
          ..write('seenCount: $seenCount, ')
          ..write('answeredCorrect: $answeredCorrect, ')
          ..write('answeredWrong: $answeredWrong, ')
          ..write('lastAnswerCorrect: $lastAnswerCorrect, ')
          ..write('lastSeenAt: $lastSeenAt, ')
          ..write('saved: $saved, ')
          ..write('savedUpdatedAt: $savedUpdatedAt, ')
          ..write('reported: $reported, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    itemId,
    seenCount,
    answeredCorrect,
    answeredWrong,
    lastAnswerCorrect,
    lastSeenAt,
    saved,
    savedUpdatedAt,
    reported,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ProgressRow &&
          other.itemId == this.itemId &&
          other.seenCount == this.seenCount &&
          other.answeredCorrect == this.answeredCorrect &&
          other.answeredWrong == this.answeredWrong &&
          other.lastAnswerCorrect == this.lastAnswerCorrect &&
          other.lastSeenAt == this.lastSeenAt &&
          other.saved == this.saved &&
          other.savedUpdatedAt == this.savedUpdatedAt &&
          other.reported == this.reported &&
          other.updatedAt == this.updatedAt);
}

class UserProgressCompanion extends UpdateCompanion<ProgressRow> {
  final Value<String> itemId;
  final Value<int> seenCount;
  final Value<int> answeredCorrect;
  final Value<int> answeredWrong;
  final Value<bool?> lastAnswerCorrect;
  final Value<DateTime?> lastSeenAt;
  final Value<bool> saved;
  final Value<DateTime?> savedUpdatedAt;
  final Value<bool> reported;
  final Value<DateTime?> updatedAt;
  final Value<int> rowid;
  const UserProgressCompanion({
    this.itemId = const Value.absent(),
    this.seenCount = const Value.absent(),
    this.answeredCorrect = const Value.absent(),
    this.answeredWrong = const Value.absent(),
    this.lastAnswerCorrect = const Value.absent(),
    this.lastSeenAt = const Value.absent(),
    this.saved = const Value.absent(),
    this.savedUpdatedAt = const Value.absent(),
    this.reported = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  UserProgressCompanion.insert({
    required String itemId,
    this.seenCount = const Value.absent(),
    this.answeredCorrect = const Value.absent(),
    this.answeredWrong = const Value.absent(),
    this.lastAnswerCorrect = const Value.absent(),
    this.lastSeenAt = const Value.absent(),
    this.saved = const Value.absent(),
    this.savedUpdatedAt = const Value.absent(),
    this.reported = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : itemId = Value(itemId);
  static Insertable<ProgressRow> custom({
    Expression<String>? itemId,
    Expression<int>? seenCount,
    Expression<int>? answeredCorrect,
    Expression<int>? answeredWrong,
    Expression<bool>? lastAnswerCorrect,
    Expression<DateTime>? lastSeenAt,
    Expression<bool>? saved,
    Expression<DateTime>? savedUpdatedAt,
    Expression<bool>? reported,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (itemId != null) 'item_id': itemId,
      if (seenCount != null) 'seen_count': seenCount,
      if (answeredCorrect != null) 'answered_correct': answeredCorrect,
      if (answeredWrong != null) 'answered_wrong': answeredWrong,
      if (lastAnswerCorrect != null) 'last_answer_correct': lastAnswerCorrect,
      if (lastSeenAt != null) 'last_seen_at': lastSeenAt,
      if (saved != null) 'saved': saved,
      if (savedUpdatedAt != null) 'saved_updated_at': savedUpdatedAt,
      if (reported != null) 'reported': reported,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  UserProgressCompanion copyWith({
    Value<String>? itemId,
    Value<int>? seenCount,
    Value<int>? answeredCorrect,
    Value<int>? answeredWrong,
    Value<bool?>? lastAnswerCorrect,
    Value<DateTime?>? lastSeenAt,
    Value<bool>? saved,
    Value<DateTime?>? savedUpdatedAt,
    Value<bool>? reported,
    Value<DateTime?>? updatedAt,
    Value<int>? rowid,
  }) {
    return UserProgressCompanion(
      itemId: itemId ?? this.itemId,
      seenCount: seenCount ?? this.seenCount,
      answeredCorrect: answeredCorrect ?? this.answeredCorrect,
      answeredWrong: answeredWrong ?? this.answeredWrong,
      lastAnswerCorrect: lastAnswerCorrect ?? this.lastAnswerCorrect,
      lastSeenAt: lastSeenAt ?? this.lastSeenAt,
      saved: saved ?? this.saved,
      savedUpdatedAt: savedUpdatedAt ?? this.savedUpdatedAt,
      reported: reported ?? this.reported,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (itemId.present) {
      map['item_id'] = Variable<String>(itemId.value);
    }
    if (seenCount.present) {
      map['seen_count'] = Variable<int>(seenCount.value);
    }
    if (answeredCorrect.present) {
      map['answered_correct'] = Variable<int>(answeredCorrect.value);
    }
    if (answeredWrong.present) {
      map['answered_wrong'] = Variable<int>(answeredWrong.value);
    }
    if (lastAnswerCorrect.present) {
      map['last_answer_correct'] = Variable<bool>(lastAnswerCorrect.value);
    }
    if (lastSeenAt.present) {
      map['last_seen_at'] = Variable<DateTime>(lastSeenAt.value);
    }
    if (saved.present) {
      map['saved'] = Variable<bool>(saved.value);
    }
    if (savedUpdatedAt.present) {
      map['saved_updated_at'] = Variable<DateTime>(savedUpdatedAt.value);
    }
    if (reported.present) {
      map['reported'] = Variable<bool>(reported.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('UserProgressCompanion(')
          ..write('itemId: $itemId, ')
          ..write('seenCount: $seenCount, ')
          ..write('answeredCorrect: $answeredCorrect, ')
          ..write('answeredWrong: $answeredWrong, ')
          ..write('lastAnswerCorrect: $lastAnswerCorrect, ')
          ..write('lastSeenAt: $lastSeenAt, ')
          ..write('saved: $saved, ')
          ..write('savedUpdatedAt: $savedUpdatedAt, ')
          ..write('reported: $reported, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $DailyActivityEntriesTable extends DailyActivityEntries
    with TableInfo<$DailyActivityEntriesTable, DailyActivityRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DailyActivityEntriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _dayMeta = const VerificationMeta('day');
  @override
  late final GeneratedColumn<String> day = GeneratedColumn<String>(
    'day',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _topicsMeta = const VerificationMeta('topics');
  @override
  late final GeneratedColumn<String> topics = GeneratedColumn<String>(
    'topics',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _itemsCompletedMeta = const VerificationMeta(
    'itemsCompleted',
  );
  @override
  late final GeneratedColumn<int> itemsCompleted = GeneratedColumn<int>(
    'items_completed',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  List<GeneratedColumn> get $columns => [day, topics, itemsCompleted];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'daily_activity';
  @override
  VerificationContext validateIntegrity(
    Insertable<DailyActivityRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('day')) {
      context.handle(
        _dayMeta,
        day.isAcceptableOrUnknown(data['day']!, _dayMeta),
      );
    } else if (isInserting) {
      context.missing(_dayMeta);
    }
    if (data.containsKey('topics')) {
      context.handle(
        _topicsMeta,
        topics.isAcceptableOrUnknown(data['topics']!, _topicsMeta),
      );
    } else if (isInserting) {
      context.missing(_topicsMeta);
    }
    if (data.containsKey('items_completed')) {
      context.handle(
        _itemsCompletedMeta,
        itemsCompleted.isAcceptableOrUnknown(
          data['items_completed']!,
          _itemsCompletedMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {day};
  @override
  DailyActivityRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DailyActivityRow(
      day: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}day'],
      )!,
      topics: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}topics'],
      )!,
      itemsCompleted: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}items_completed'],
      )!,
    );
  }

  @override
  $DailyActivityEntriesTable createAlias(String alias) {
    return $DailyActivityEntriesTable(attachedDatabase, alias);
  }
}

class DailyActivityRow extends DataClass
    implements Insertable<DailyActivityRow> {
  final String day;
  final String topics;
  final int itemsCompleted;
  const DailyActivityRow({
    required this.day,
    required this.topics,
    required this.itemsCompleted,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['day'] = Variable<String>(day);
    map['topics'] = Variable<String>(topics);
    map['items_completed'] = Variable<int>(itemsCompleted);
    return map;
  }

  DailyActivityEntriesCompanion toCompanion(bool nullToAbsent) {
    return DailyActivityEntriesCompanion(
      day: Value(day),
      topics: Value(topics),
      itemsCompleted: Value(itemsCompleted),
    );
  }

  factory DailyActivityRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DailyActivityRow(
      day: serializer.fromJson<String>(json['day']),
      topics: serializer.fromJson<String>(json['topics']),
      itemsCompleted: serializer.fromJson<int>(json['itemsCompleted']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'day': serializer.toJson<String>(day),
      'topics': serializer.toJson<String>(topics),
      'itemsCompleted': serializer.toJson<int>(itemsCompleted),
    };
  }

  DailyActivityRow copyWith({
    String? day,
    String? topics,
    int? itemsCompleted,
  }) => DailyActivityRow(
    day: day ?? this.day,
    topics: topics ?? this.topics,
    itemsCompleted: itemsCompleted ?? this.itemsCompleted,
  );
  DailyActivityRow copyWithCompanion(DailyActivityEntriesCompanion data) {
    return DailyActivityRow(
      day: data.day.present ? data.day.value : this.day,
      topics: data.topics.present ? data.topics.value : this.topics,
      itemsCompleted: data.itemsCompleted.present
          ? data.itemsCompleted.value
          : this.itemsCompleted,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DailyActivityRow(')
          ..write('day: $day, ')
          ..write('topics: $topics, ')
          ..write('itemsCompleted: $itemsCompleted')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(day, topics, itemsCompleted);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DailyActivityRow &&
          other.day == this.day &&
          other.topics == this.topics &&
          other.itemsCompleted == this.itemsCompleted);
}

class DailyActivityEntriesCompanion extends UpdateCompanion<DailyActivityRow> {
  final Value<String> day;
  final Value<String> topics;
  final Value<int> itemsCompleted;
  final Value<int> rowid;
  const DailyActivityEntriesCompanion({
    this.day = const Value.absent(),
    this.topics = const Value.absent(),
    this.itemsCompleted = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  DailyActivityEntriesCompanion.insert({
    required String day,
    required String topics,
    this.itemsCompleted = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : day = Value(day),
       topics = Value(topics);
  static Insertable<DailyActivityRow> custom({
    Expression<String>? day,
    Expression<String>? topics,
    Expression<int>? itemsCompleted,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (day != null) 'day': day,
      if (topics != null) 'topics': topics,
      if (itemsCompleted != null) 'items_completed': itemsCompleted,
      if (rowid != null) 'rowid': rowid,
    });
  }

  DailyActivityEntriesCompanion copyWith({
    Value<String>? day,
    Value<String>? topics,
    Value<int>? itemsCompleted,
    Value<int>? rowid,
  }) {
    return DailyActivityEntriesCompanion(
      day: day ?? this.day,
      topics: topics ?? this.topics,
      itemsCompleted: itemsCompleted ?? this.itemsCompleted,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (day.present) {
      map['day'] = Variable<String>(day.value);
    }
    if (topics.present) {
      map['topics'] = Variable<String>(topics.value);
    }
    if (itemsCompleted.present) {
      map['items_completed'] = Variable<int>(itemsCompleted.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DailyActivityEntriesCompanion(')
          ..write('day: $day, ')
          ..write('topics: $topics, ')
          ..write('itemsCompleted: $itemsCompleted, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $EssaysTable extends Essays with TableInfo<$EssaysTable, EssayRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $EssaysTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _promptMeta = const VerificationMeta('prompt');
  @override
  late final GeneratedColumn<String> prompt = GeneratedColumn<String>(
    'prompt',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _localImagePathMeta = const VerificationMeta(
    'localImagePath',
  );
  @override
  late final GeneratedColumn<String> localImagePath = GeneratedColumn<String>(
    'local_image_path',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _imagePathMeta = const VerificationMeta(
    'imagePath',
  );
  @override
  late final GeneratedColumn<String> imagePath = GeneratedColumn<String>(
    'image_path',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _extractedTextMeta = const VerificationMeta(
    'extractedText',
  );
  @override
  late final GeneratedColumn<String> extractedText = GeneratedColumn<String>(
    'extracted_text',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _scoreTotalMeta = const VerificationMeta(
    'scoreTotal',
  );
  @override
  late final GeneratedColumn<int> scoreTotal = GeneratedColumn<int>(
    'score_total',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _resultJsonMeta = const VerificationMeta(
    'resultJson',
  );
  @override
  late final GeneratedColumn<String> resultJson = GeneratedColumn<String>(
    'result_json',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _errorMessageMeta = const VerificationMeta(
    'errorMessage',
  );
  @override
  late final GeneratedColumn<String> errorMessage = GeneratedColumn<String>(
    'error_message',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    prompt,
    localImagePath,
    imagePath,
    extractedText,
    scoreTotal,
    resultJson,
    status,
    errorMessage,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'essays';
  @override
  VerificationContext validateIntegrity(
    Insertable<EssayRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('prompt')) {
      context.handle(
        _promptMeta,
        prompt.isAcceptableOrUnknown(data['prompt']!, _promptMeta),
      );
    } else if (isInserting) {
      context.missing(_promptMeta);
    }
    if (data.containsKey('local_image_path')) {
      context.handle(
        _localImagePathMeta,
        localImagePath.isAcceptableOrUnknown(
          data['local_image_path']!,
          _localImagePathMeta,
        ),
      );
    }
    if (data.containsKey('image_path')) {
      context.handle(
        _imagePathMeta,
        imagePath.isAcceptableOrUnknown(data['image_path']!, _imagePathMeta),
      );
    }
    if (data.containsKey('extracted_text')) {
      context.handle(
        _extractedTextMeta,
        extractedText.isAcceptableOrUnknown(
          data['extracted_text']!,
          _extractedTextMeta,
        ),
      );
    }
    if (data.containsKey('score_total')) {
      context.handle(
        _scoreTotalMeta,
        scoreTotal.isAcceptableOrUnknown(data['score_total']!, _scoreTotalMeta),
      );
    }
    if (data.containsKey('result_json')) {
      context.handle(
        _resultJsonMeta,
        resultJson.isAcceptableOrUnknown(data['result_json']!, _resultJsonMeta),
      );
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    if (data.containsKey('error_message')) {
      context.handle(
        _errorMessageMeta,
        errorMessage.isAcceptableOrUnknown(
          data['error_message']!,
          _errorMessageMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  EssayRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return EssayRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      prompt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}prompt'],
      )!,
      localImagePath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}local_image_path'],
      ),
      imagePath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}image_path'],
      ),
      extractedText: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}extracted_text'],
      ),
      scoreTotal: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}score_total'],
      ),
      resultJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}result_json'],
      ),
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      errorMessage: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}error_message'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $EssaysTable createAlias(String alias) {
    return $EssaysTable(attachedDatabase, alias);
  }
}

class EssayRow extends DataClass implements Insertable<EssayRow> {
  final String id;
  final String prompt;
  final String? localImagePath;
  final String? imagePath;
  final String? extractedText;
  final int? scoreTotal;
  final String? resultJson;
  final String status;
  final String? errorMessage;
  final DateTime createdAt;
  const EssayRow({
    required this.id,
    required this.prompt,
    this.localImagePath,
    this.imagePath,
    this.extractedText,
    this.scoreTotal,
    this.resultJson,
    required this.status,
    this.errorMessage,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['prompt'] = Variable<String>(prompt);
    if (!nullToAbsent || localImagePath != null) {
      map['local_image_path'] = Variable<String>(localImagePath);
    }
    if (!nullToAbsent || imagePath != null) {
      map['image_path'] = Variable<String>(imagePath);
    }
    if (!nullToAbsent || extractedText != null) {
      map['extracted_text'] = Variable<String>(extractedText);
    }
    if (!nullToAbsent || scoreTotal != null) {
      map['score_total'] = Variable<int>(scoreTotal);
    }
    if (!nullToAbsent || resultJson != null) {
      map['result_json'] = Variable<String>(resultJson);
    }
    map['status'] = Variable<String>(status);
    if (!nullToAbsent || errorMessage != null) {
      map['error_message'] = Variable<String>(errorMessage);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  EssaysCompanion toCompanion(bool nullToAbsent) {
    return EssaysCompanion(
      id: Value(id),
      prompt: Value(prompt),
      localImagePath: localImagePath == null && nullToAbsent
          ? const Value.absent()
          : Value(localImagePath),
      imagePath: imagePath == null && nullToAbsent
          ? const Value.absent()
          : Value(imagePath),
      extractedText: extractedText == null && nullToAbsent
          ? const Value.absent()
          : Value(extractedText),
      scoreTotal: scoreTotal == null && nullToAbsent
          ? const Value.absent()
          : Value(scoreTotal),
      resultJson: resultJson == null && nullToAbsent
          ? const Value.absent()
          : Value(resultJson),
      status: Value(status),
      errorMessage: errorMessage == null && nullToAbsent
          ? const Value.absent()
          : Value(errorMessage),
      createdAt: Value(createdAt),
    );
  }

  factory EssayRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return EssayRow(
      id: serializer.fromJson<String>(json['id']),
      prompt: serializer.fromJson<String>(json['prompt']),
      localImagePath: serializer.fromJson<String?>(json['localImagePath']),
      imagePath: serializer.fromJson<String?>(json['imagePath']),
      extractedText: serializer.fromJson<String?>(json['extractedText']),
      scoreTotal: serializer.fromJson<int?>(json['scoreTotal']),
      resultJson: serializer.fromJson<String?>(json['resultJson']),
      status: serializer.fromJson<String>(json['status']),
      errorMessage: serializer.fromJson<String?>(json['errorMessage']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'prompt': serializer.toJson<String>(prompt),
      'localImagePath': serializer.toJson<String?>(localImagePath),
      'imagePath': serializer.toJson<String?>(imagePath),
      'extractedText': serializer.toJson<String?>(extractedText),
      'scoreTotal': serializer.toJson<int?>(scoreTotal),
      'resultJson': serializer.toJson<String?>(resultJson),
      'status': serializer.toJson<String>(status),
      'errorMessage': serializer.toJson<String?>(errorMessage),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  EssayRow copyWith({
    String? id,
    String? prompt,
    Value<String?> localImagePath = const Value.absent(),
    Value<String?> imagePath = const Value.absent(),
    Value<String?> extractedText = const Value.absent(),
    Value<int?> scoreTotal = const Value.absent(),
    Value<String?> resultJson = const Value.absent(),
    String? status,
    Value<String?> errorMessage = const Value.absent(),
    DateTime? createdAt,
  }) => EssayRow(
    id: id ?? this.id,
    prompt: prompt ?? this.prompt,
    localImagePath: localImagePath.present
        ? localImagePath.value
        : this.localImagePath,
    imagePath: imagePath.present ? imagePath.value : this.imagePath,
    extractedText: extractedText.present
        ? extractedText.value
        : this.extractedText,
    scoreTotal: scoreTotal.present ? scoreTotal.value : this.scoreTotal,
    resultJson: resultJson.present ? resultJson.value : this.resultJson,
    status: status ?? this.status,
    errorMessage: errorMessage.present ? errorMessage.value : this.errorMessage,
    createdAt: createdAt ?? this.createdAt,
  );
  EssayRow copyWithCompanion(EssaysCompanion data) {
    return EssayRow(
      id: data.id.present ? data.id.value : this.id,
      prompt: data.prompt.present ? data.prompt.value : this.prompt,
      localImagePath: data.localImagePath.present
          ? data.localImagePath.value
          : this.localImagePath,
      imagePath: data.imagePath.present ? data.imagePath.value : this.imagePath,
      extractedText: data.extractedText.present
          ? data.extractedText.value
          : this.extractedText,
      scoreTotal: data.scoreTotal.present
          ? data.scoreTotal.value
          : this.scoreTotal,
      resultJson: data.resultJson.present
          ? data.resultJson.value
          : this.resultJson,
      status: data.status.present ? data.status.value : this.status,
      errorMessage: data.errorMessage.present
          ? data.errorMessage.value
          : this.errorMessage,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('EssayRow(')
          ..write('id: $id, ')
          ..write('prompt: $prompt, ')
          ..write('localImagePath: $localImagePath, ')
          ..write('imagePath: $imagePath, ')
          ..write('extractedText: $extractedText, ')
          ..write('scoreTotal: $scoreTotal, ')
          ..write('resultJson: $resultJson, ')
          ..write('status: $status, ')
          ..write('errorMessage: $errorMessage, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    prompt,
    localImagePath,
    imagePath,
    extractedText,
    scoreTotal,
    resultJson,
    status,
    errorMessage,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is EssayRow &&
          other.id == this.id &&
          other.prompt == this.prompt &&
          other.localImagePath == this.localImagePath &&
          other.imagePath == this.imagePath &&
          other.extractedText == this.extractedText &&
          other.scoreTotal == this.scoreTotal &&
          other.resultJson == this.resultJson &&
          other.status == this.status &&
          other.errorMessage == this.errorMessage &&
          other.createdAt == this.createdAt);
}

class EssaysCompanion extends UpdateCompanion<EssayRow> {
  final Value<String> id;
  final Value<String> prompt;
  final Value<String?> localImagePath;
  final Value<String?> imagePath;
  final Value<String?> extractedText;
  final Value<int?> scoreTotal;
  final Value<String?> resultJson;
  final Value<String> status;
  final Value<String?> errorMessage;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const EssaysCompanion({
    this.id = const Value.absent(),
    this.prompt = const Value.absent(),
    this.localImagePath = const Value.absent(),
    this.imagePath = const Value.absent(),
    this.extractedText = const Value.absent(),
    this.scoreTotal = const Value.absent(),
    this.resultJson = const Value.absent(),
    this.status = const Value.absent(),
    this.errorMessage = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  EssaysCompanion.insert({
    required String id,
    required String prompt,
    this.localImagePath = const Value.absent(),
    this.imagePath = const Value.absent(),
    this.extractedText = const Value.absent(),
    this.scoreTotal = const Value.absent(),
    this.resultJson = const Value.absent(),
    required String status,
    this.errorMessage = const Value.absent(),
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       prompt = Value(prompt),
       status = Value(status),
       createdAt = Value(createdAt);
  static Insertable<EssayRow> custom({
    Expression<String>? id,
    Expression<String>? prompt,
    Expression<String>? localImagePath,
    Expression<String>? imagePath,
    Expression<String>? extractedText,
    Expression<int>? scoreTotal,
    Expression<String>? resultJson,
    Expression<String>? status,
    Expression<String>? errorMessage,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (prompt != null) 'prompt': prompt,
      if (localImagePath != null) 'local_image_path': localImagePath,
      if (imagePath != null) 'image_path': imagePath,
      if (extractedText != null) 'extracted_text': extractedText,
      if (scoreTotal != null) 'score_total': scoreTotal,
      if (resultJson != null) 'result_json': resultJson,
      if (status != null) 'status': status,
      if (errorMessage != null) 'error_message': errorMessage,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  EssaysCompanion copyWith({
    Value<String>? id,
    Value<String>? prompt,
    Value<String?>? localImagePath,
    Value<String?>? imagePath,
    Value<String?>? extractedText,
    Value<int?>? scoreTotal,
    Value<String?>? resultJson,
    Value<String>? status,
    Value<String?>? errorMessage,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return EssaysCompanion(
      id: id ?? this.id,
      prompt: prompt ?? this.prompt,
      localImagePath: localImagePath ?? this.localImagePath,
      imagePath: imagePath ?? this.imagePath,
      extractedText: extractedText ?? this.extractedText,
      scoreTotal: scoreTotal ?? this.scoreTotal,
      resultJson: resultJson ?? this.resultJson,
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (prompt.present) {
      map['prompt'] = Variable<String>(prompt.value);
    }
    if (localImagePath.present) {
      map['local_image_path'] = Variable<String>(localImagePath.value);
    }
    if (imagePath.present) {
      map['image_path'] = Variable<String>(imagePath.value);
    }
    if (extractedText.present) {
      map['extracted_text'] = Variable<String>(extractedText.value);
    }
    if (scoreTotal.present) {
      map['score_total'] = Variable<int>(scoreTotal.value);
    }
    if (resultJson.present) {
      map['result_json'] = Variable<String>(resultJson.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (errorMessage.present) {
      map['error_message'] = Variable<String>(errorMessage.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('EssaysCompanion(')
          ..write('id: $id, ')
          ..write('prompt: $prompt, ')
          ..write('localImagePath: $localImagePath, ')
          ..write('imagePath: $imagePath, ')
          ..write('extractedText: $extractedText, ')
          ..write('scoreTotal: $scoreTotal, ')
          ..write('resultJson: $resultJson, ')
          ..write('status: $status, ')
          ..write('errorMessage: $errorMessage, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SettingsTable extends Settings
    with TableInfo<$SettingsTable, SettingRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SettingsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _keyMeta = const VerificationMeta('key');
  @override
  late final GeneratedColumn<String> key = GeneratedColumn<String>(
    'key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _valueMeta = const VerificationMeta('value');
  @override
  late final GeneratedColumn<String> value = GeneratedColumn<String>(
    'value',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [key, value];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'settings';
  @override
  VerificationContext validateIntegrity(
    Insertable<SettingRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('key')) {
      context.handle(
        _keyMeta,
        key.isAcceptableOrUnknown(data['key']!, _keyMeta),
      );
    } else if (isInserting) {
      context.missing(_keyMeta);
    }
    if (data.containsKey('value')) {
      context.handle(
        _valueMeta,
        value.isAcceptableOrUnknown(data['value']!, _valueMeta),
      );
    } else if (isInserting) {
      context.missing(_valueMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {key};
  @override
  SettingRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SettingRow(
      key: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}key'],
      )!,
      value: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}value'],
      )!,
    );
  }

  @override
  $SettingsTable createAlias(String alias) {
    return $SettingsTable(attachedDatabase, alias);
  }
}

class SettingRow extends DataClass implements Insertable<SettingRow> {
  final String key;
  final String value;
  const SettingRow({required this.key, required this.value});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['key'] = Variable<String>(key);
    map['value'] = Variable<String>(value);
    return map;
  }

  SettingsCompanion toCompanion(bool nullToAbsent) {
    return SettingsCompanion(key: Value(key), value: Value(value));
  }

  factory SettingRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SettingRow(
      key: serializer.fromJson<String>(json['key']),
      value: serializer.fromJson<String>(json['value']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'key': serializer.toJson<String>(key),
      'value': serializer.toJson<String>(value),
    };
  }

  SettingRow copyWith({String? key, String? value}) =>
      SettingRow(key: key ?? this.key, value: value ?? this.value);
  SettingRow copyWithCompanion(SettingsCompanion data) {
    return SettingRow(
      key: data.key.present ? data.key.value : this.key,
      value: data.value.present ? data.value.value : this.value,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SettingRow(')
          ..write('key: $key, ')
          ..write('value: $value')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(key, value);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SettingRow &&
          other.key == this.key &&
          other.value == this.value);
}

class SettingsCompanion extends UpdateCompanion<SettingRow> {
  final Value<String> key;
  final Value<String> value;
  final Value<int> rowid;
  const SettingsCompanion({
    this.key = const Value.absent(),
    this.value = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SettingsCompanion.insert({
    required String key,
    required String value,
    this.rowid = const Value.absent(),
  }) : key = Value(key),
       value = Value(value);
  static Insertable<SettingRow> custom({
    Expression<String>? key,
    Expression<String>? value,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (key != null) 'key': key,
      if (value != null) 'value': value,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SettingsCompanion copyWith({
    Value<String>? key,
    Value<String>? value,
    Value<int>? rowid,
  }) {
    return SettingsCompanion(
      key: key ?? this.key,
      value: value ?? this.value,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (key.present) {
      map['key'] = Variable<String>(key.value);
    }
    if (value.present) {
      map['value'] = Variable<String>(value.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SettingsCompanion(')
          ..write('key: $key, ')
          ..write('value: $value, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SyncQueueTable extends SyncQueue
    with TableInfo<$SyncQueueTable, SyncQueueRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SyncQueueTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _entityMeta = const VerificationMeta('entity');
  @override
  late final GeneratedColumn<String> entity = GeneratedColumn<String>(
    'entity',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _entityKeyMeta = const VerificationMeta(
    'entityKey',
  );
  @override
  late final GeneratedColumn<String> entityKey = GeneratedColumn<String>(
    'entity_key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _payloadJsonMeta = const VerificationMeta(
    'payloadJson',
  );
  @override
  late final GeneratedColumn<String> payloadJson = GeneratedColumn<String>(
    'payload_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _attemptsMeta = const VerificationMeta(
    'attempts',
  );
  @override
  late final GeneratedColumn<int> attempts = GeneratedColumn<int>(
    'attempts',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    entity,
    entityKey,
    payloadJson,
    createdAt,
    attempts,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sync_queue';
  @override
  VerificationContext validateIntegrity(
    Insertable<SyncQueueRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('entity')) {
      context.handle(
        _entityMeta,
        entity.isAcceptableOrUnknown(data['entity']!, _entityMeta),
      );
    } else if (isInserting) {
      context.missing(_entityMeta);
    }
    if (data.containsKey('entity_key')) {
      context.handle(
        _entityKeyMeta,
        entityKey.isAcceptableOrUnknown(data['entity_key']!, _entityKeyMeta),
      );
    } else if (isInserting) {
      context.missing(_entityKeyMeta);
    }
    if (data.containsKey('payload_json')) {
      context.handle(
        _payloadJsonMeta,
        payloadJson.isAcceptableOrUnknown(
          data['payload_json']!,
          _payloadJsonMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_payloadJsonMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('attempts')) {
      context.handle(
        _attemptsMeta,
        attempts.isAcceptableOrUnknown(data['attempts']!, _attemptsMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SyncQueueRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SyncQueueRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      entity: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}entity'],
      )!,
      entityKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}entity_key'],
      )!,
      payloadJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}payload_json'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      attempts: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}attempts'],
      )!,
    );
  }

  @override
  $SyncQueueTable createAlias(String alias) {
    return $SyncQueueTable(attachedDatabase, alias);
  }
}

class SyncQueueRow extends DataClass implements Insertable<SyncQueueRow> {
  final int id;
  final String entity;
  final String entityKey;
  final String payloadJson;
  final DateTime createdAt;
  final int attempts;
  const SyncQueueRow({
    required this.id,
    required this.entity,
    required this.entityKey,
    required this.payloadJson,
    required this.createdAt,
    required this.attempts,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['entity'] = Variable<String>(entity);
    map['entity_key'] = Variable<String>(entityKey);
    map['payload_json'] = Variable<String>(payloadJson);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['attempts'] = Variable<int>(attempts);
    return map;
  }

  SyncQueueCompanion toCompanion(bool nullToAbsent) {
    return SyncQueueCompanion(
      id: Value(id),
      entity: Value(entity),
      entityKey: Value(entityKey),
      payloadJson: Value(payloadJson),
      createdAt: Value(createdAt),
      attempts: Value(attempts),
    );
  }

  factory SyncQueueRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SyncQueueRow(
      id: serializer.fromJson<int>(json['id']),
      entity: serializer.fromJson<String>(json['entity']),
      entityKey: serializer.fromJson<String>(json['entityKey']),
      payloadJson: serializer.fromJson<String>(json['payloadJson']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      attempts: serializer.fromJson<int>(json['attempts']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'entity': serializer.toJson<String>(entity),
      'entityKey': serializer.toJson<String>(entityKey),
      'payloadJson': serializer.toJson<String>(payloadJson),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'attempts': serializer.toJson<int>(attempts),
    };
  }

  SyncQueueRow copyWith({
    int? id,
    String? entity,
    String? entityKey,
    String? payloadJson,
    DateTime? createdAt,
    int? attempts,
  }) => SyncQueueRow(
    id: id ?? this.id,
    entity: entity ?? this.entity,
    entityKey: entityKey ?? this.entityKey,
    payloadJson: payloadJson ?? this.payloadJson,
    createdAt: createdAt ?? this.createdAt,
    attempts: attempts ?? this.attempts,
  );
  SyncQueueRow copyWithCompanion(SyncQueueCompanion data) {
    return SyncQueueRow(
      id: data.id.present ? data.id.value : this.id,
      entity: data.entity.present ? data.entity.value : this.entity,
      entityKey: data.entityKey.present ? data.entityKey.value : this.entityKey,
      payloadJson: data.payloadJson.present
          ? data.payloadJson.value
          : this.payloadJson,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      attempts: data.attempts.present ? data.attempts.value : this.attempts,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SyncQueueRow(')
          ..write('id: $id, ')
          ..write('entity: $entity, ')
          ..write('entityKey: $entityKey, ')
          ..write('payloadJson: $payloadJson, ')
          ..write('createdAt: $createdAt, ')
          ..write('attempts: $attempts')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, entity, entityKey, payloadJson, createdAt, attempts);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SyncQueueRow &&
          other.id == this.id &&
          other.entity == this.entity &&
          other.entityKey == this.entityKey &&
          other.payloadJson == this.payloadJson &&
          other.createdAt == this.createdAt &&
          other.attempts == this.attempts);
}

class SyncQueueCompanion extends UpdateCompanion<SyncQueueRow> {
  final Value<int> id;
  final Value<String> entity;
  final Value<String> entityKey;
  final Value<String> payloadJson;
  final Value<DateTime> createdAt;
  final Value<int> attempts;
  const SyncQueueCompanion({
    this.id = const Value.absent(),
    this.entity = const Value.absent(),
    this.entityKey = const Value.absent(),
    this.payloadJson = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.attempts = const Value.absent(),
  });
  SyncQueueCompanion.insert({
    this.id = const Value.absent(),
    required String entity,
    required String entityKey,
    required String payloadJson,
    required DateTime createdAt,
    this.attempts = const Value.absent(),
  }) : entity = Value(entity),
       entityKey = Value(entityKey),
       payloadJson = Value(payloadJson),
       createdAt = Value(createdAt);
  static Insertable<SyncQueueRow> custom({
    Expression<int>? id,
    Expression<String>? entity,
    Expression<String>? entityKey,
    Expression<String>? payloadJson,
    Expression<DateTime>? createdAt,
    Expression<int>? attempts,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (entity != null) 'entity': entity,
      if (entityKey != null) 'entity_key': entityKey,
      if (payloadJson != null) 'payload_json': payloadJson,
      if (createdAt != null) 'created_at': createdAt,
      if (attempts != null) 'attempts': attempts,
    });
  }

  SyncQueueCompanion copyWith({
    Value<int>? id,
    Value<String>? entity,
    Value<String>? entityKey,
    Value<String>? payloadJson,
    Value<DateTime>? createdAt,
    Value<int>? attempts,
  }) {
    return SyncQueueCompanion(
      id: id ?? this.id,
      entity: entity ?? this.entity,
      entityKey: entityKey ?? this.entityKey,
      payloadJson: payloadJson ?? this.payloadJson,
      createdAt: createdAt ?? this.createdAt,
      attempts: attempts ?? this.attempts,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (entity.present) {
      map['entity'] = Variable<String>(entity.value);
    }
    if (entityKey.present) {
      map['entity_key'] = Variable<String>(entityKey.value);
    }
    if (payloadJson.present) {
      map['payload_json'] = Variable<String>(payloadJson.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (attempts.present) {
      map['attempts'] = Variable<int>(attempts.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SyncQueueCompanion(')
          ..write('id: $id, ')
          ..write('entity: $entity, ')
          ..write('entityKey: $entityKey, ')
          ..write('payloadJson: $payloadJson, ')
          ..write('createdAt: $createdAt, ')
          ..write('attempts: $attempts')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $TopicsTable topics = $TopicsTable(this);
  late final $ContentItemsTable contentItems = $ContentItemsTable(this);
  late final $EssayPromptsTable essayPrompts = $EssayPromptsTable(this);
  late final $UserProgressTable userProgress = $UserProgressTable(this);
  late final $DailyActivityEntriesTable dailyActivityEntries =
      $DailyActivityEntriesTable(this);
  late final $EssaysTable essays = $EssaysTable(this);
  late final $SettingsTable settings = $SettingsTable(this);
  late final $SyncQueueTable syncQueue = $SyncQueueTable(this);
  late final Index contentItemsTopicCode = Index(
    'content_items_topic_code',
    'CREATE INDEX content_items_topic_code ON content_items (topic_code, is_active)',
  );
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    topics,
    contentItems,
    essayPrompts,
    userProgress,
    dailyActivityEntries,
    essays,
    settings,
    syncQueue,
    contentItemsTopicCode,
  ];
}

typedef $$TopicsTableCreateCompanionBuilder = TopicsCompanion Function({
  required String code,
  required String name,
  required String icon,
  required int sortOrder,
  Value<int> rowid,
});
typedef $$TopicsTableUpdateCompanionBuilder = TopicsCompanion Function({
  Value<String> code,
  Value<String> name,
  Value<String> icon,
  Value<int> sortOrder,
  Value<int> rowid,
});

class $$TopicsTableFilterComposer
    extends Composer<_$AppDatabase, $TopicsTable> {
  $$TopicsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get code => $composableBuilder(
    column: $table.code,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get icon => $composableBuilder(
    column: $table.icon,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnFilters(column),
  );
}

class $$TopicsTableOrderingComposer
    extends Composer<_$AppDatabase, $TopicsTable> {
  $$TopicsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get code => $composableBuilder(
    column: $table.code,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get icon => $composableBuilder(
    column: $table.icon,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$TopicsTableAnnotationComposer
    extends Composer<_$AppDatabase, $TopicsTable> {
  $$TopicsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get code =>
      $composableBuilder(column: $table.code, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get icon =>
      $composableBuilder(column: $table.icon, builder: (column) => column);

  GeneratedColumn<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);
}

class $$TopicsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TopicsTable,
          TopicRow,
          $$TopicsTableFilterComposer,
          $$TopicsTableOrderingComposer,
          $$TopicsTableAnnotationComposer,
          $$TopicsTableCreateCompanionBuilder,
          $$TopicsTableUpdateCompanionBuilder,
          (TopicRow, BaseReferences<_$AppDatabase, $TopicsTable, TopicRow>),
          TopicRow,
          PrefetchHooks Function()
        > {
  $$TopicsTableTableManager(_$AppDatabase db, $TopicsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TopicsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TopicsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TopicsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> code = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> icon = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TopicsCompanion(
                code: code,
                name: name,
                icon: icon,
                sortOrder: sortOrder,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String code,
                required String name,
                required String icon,
                required int sortOrder,
                Value<int> rowid = const Value.absent(),
              }) => TopicsCompanion.insert(
                code: code,
                name: name,
                icon: icon,
                sortOrder: sortOrder,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$TopicsTable, TopicRow>(table),
                  BaseReferences<_$AppDatabase, $TopicsTable, TopicRow>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$TopicsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TopicsTable,
      TopicRow,
      $$TopicsTableFilterComposer,
      $$TopicsTableOrderingComposer,
      $$TopicsTableAnnotationComposer,
      $$TopicsTableCreateCompanionBuilder,
      $$TopicsTableUpdateCompanionBuilder,
      (TopicRow, BaseReferences<_$AppDatabase, $TopicsTable, TopicRow>),
      TopicRow,
      PrefetchHooks Function()
    >;
typedef $$ContentItemsTableCreateCompanionBuilder =
    ContentItemsCompanion Function({
      required String id,
      required String topicCode,
      required String type,
      required String title,
      required String body,
      Value<String?> statement,
      Value<bool?> isTrue,
      Value<String?> correctAnswer,
      Value<String?> explanation,
      Value<String?> term,
      Value<String?> translation,
      Value<String?> exampleSentence,
      Value<int> difficulty,
      Value<String?> sourceName,
      Value<String?> sourceUrl,
      Value<bool> verified,
      Value<bool> inOfflinePack,
      Value<bool> isActive,
      Value<DateTime?> createdAt,
      Value<DateTime?> updatedAt,
      Value<int> rowid,
    });
typedef $$ContentItemsTableUpdateCompanionBuilder =
    ContentItemsCompanion Function({
      Value<String> id,
      Value<String> topicCode,
      Value<String> type,
      Value<String> title,
      Value<String> body,
      Value<String?> statement,
      Value<bool?> isTrue,
      Value<String?> correctAnswer,
      Value<String?> explanation,
      Value<String?> term,
      Value<String?> translation,
      Value<String?> exampleSentence,
      Value<int> difficulty,
      Value<String?> sourceName,
      Value<String?> sourceUrl,
      Value<bool> verified,
      Value<bool> inOfflinePack,
      Value<bool> isActive,
      Value<DateTime?> createdAt,
      Value<DateTime?> updatedAt,
      Value<int> rowid,
    });

class $$ContentItemsTableFilterComposer
    extends Composer<_$AppDatabase, $ContentItemsTable> {
  $$ContentItemsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get topicCode => $composableBuilder(
    column: $table.topicCode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get body => $composableBuilder(
    column: $table.body,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get statement => $composableBuilder(
    column: $table.statement,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isTrue => $composableBuilder(
    column: $table.isTrue,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get correctAnswer => $composableBuilder(
    column: $table.correctAnswer,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get explanation => $composableBuilder(
    column: $table.explanation,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get term => $composableBuilder(
    column: $table.term,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get translation => $composableBuilder(
    column: $table.translation,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get exampleSentence => $composableBuilder(
    column: $table.exampleSentence,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get difficulty => $composableBuilder(
    column: $table.difficulty,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sourceName => $composableBuilder(
    column: $table.sourceName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sourceUrl => $composableBuilder(
    column: $table.sourceUrl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get verified => $composableBuilder(
    column: $table.verified,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get inOfflinePack => $composableBuilder(
    column: $table.inOfflinePack,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ContentItemsTableOrderingComposer
    extends Composer<_$AppDatabase, $ContentItemsTable> {
  $$ContentItemsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get topicCode => $composableBuilder(
    column: $table.topicCode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get body => $composableBuilder(
    column: $table.body,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get statement => $composableBuilder(
    column: $table.statement,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isTrue => $composableBuilder(
    column: $table.isTrue,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get correctAnswer => $composableBuilder(
    column: $table.correctAnswer,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get explanation => $composableBuilder(
    column: $table.explanation,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get term => $composableBuilder(
    column: $table.term,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get translation => $composableBuilder(
    column: $table.translation,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get exampleSentence => $composableBuilder(
    column: $table.exampleSentence,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get difficulty => $composableBuilder(
    column: $table.difficulty,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sourceName => $composableBuilder(
    column: $table.sourceName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sourceUrl => $composableBuilder(
    column: $table.sourceUrl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get verified => $composableBuilder(
    column: $table.verified,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get inOfflinePack => $composableBuilder(
    column: $table.inOfflinePack,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ContentItemsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ContentItemsTable> {
  $$ContentItemsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get topicCode =>
      $composableBuilder(column: $table.topicCode, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get body =>
      $composableBuilder(column: $table.body, builder: (column) => column);

  GeneratedColumn<String> get statement =>
      $composableBuilder(column: $table.statement, builder: (column) => column);

  GeneratedColumn<bool> get isTrue =>
      $composableBuilder(column: $table.isTrue, builder: (column) => column);

  GeneratedColumn<String> get correctAnswer => $composableBuilder(
    column: $table.correctAnswer,
    builder: (column) => column,
  );

  GeneratedColumn<String> get explanation => $composableBuilder(
    column: $table.explanation,
    builder: (column) => column,
  );

  GeneratedColumn<String> get term =>
      $composableBuilder(column: $table.term, builder: (column) => column);

  GeneratedColumn<String> get translation => $composableBuilder(
    column: $table.translation,
    builder: (column) => column,
  );

  GeneratedColumn<String> get exampleSentence => $composableBuilder(
    column: $table.exampleSentence,
    builder: (column) => column,
  );

  GeneratedColumn<int> get difficulty => $composableBuilder(
    column: $table.difficulty,
    builder: (column) => column,
  );

  GeneratedColumn<String> get sourceName => $composableBuilder(
    column: $table.sourceName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get sourceUrl =>
      $composableBuilder(column: $table.sourceUrl, builder: (column) => column);

  GeneratedColumn<bool> get verified =>
      $composableBuilder(column: $table.verified, builder: (column) => column);

  GeneratedColumn<bool> get inOfflinePack => $composableBuilder(
    column: $table.inOfflinePack,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isActive =>
      $composableBuilder(column: $table.isActive, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$ContentItemsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ContentItemsTable,
          ContentItemRow,
          $$ContentItemsTableFilterComposer,
          $$ContentItemsTableOrderingComposer,
          $$ContentItemsTableAnnotationComposer,
          $$ContentItemsTableCreateCompanionBuilder,
          $$ContentItemsTableUpdateCompanionBuilder,
          (
            ContentItemRow,
            BaseReferences<_$AppDatabase, $ContentItemsTable, ContentItemRow>,
          ),
          ContentItemRow,
          PrefetchHooks Function()
        > {
  $$ContentItemsTableTableManager(_$AppDatabase db, $ContentItemsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ContentItemsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ContentItemsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ContentItemsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> topicCode = const Value.absent(),
                Value<String> type = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String> body = const Value.absent(),
                Value<String?> statement = const Value.absent(),
                Value<bool?> isTrue = const Value.absent(),
                Value<String?> correctAnswer = const Value.absent(),
                Value<String?> explanation = const Value.absent(),
                Value<String?> term = const Value.absent(),
                Value<String?> translation = const Value.absent(),
                Value<String?> exampleSentence = const Value.absent(),
                Value<int> difficulty = const Value.absent(),
                Value<String?> sourceName = const Value.absent(),
                Value<String?> sourceUrl = const Value.absent(),
                Value<bool> verified = const Value.absent(),
                Value<bool> inOfflinePack = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
                Value<DateTime?> createdAt = const Value.absent(),
                Value<DateTime?> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ContentItemsCompanion(
                id: id,
                topicCode: topicCode,
                type: type,
                title: title,
                body: body,
                statement: statement,
                isTrue: isTrue,
                correctAnswer: correctAnswer,
                explanation: explanation,
                term: term,
                translation: translation,
                exampleSentence: exampleSentence,
                difficulty: difficulty,
                sourceName: sourceName,
                sourceUrl: sourceUrl,
                verified: verified,
                inOfflinePack: inOfflinePack,
                isActive: isActive,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String topicCode,
                required String type,
                required String title,
                required String body,
                Value<String?> statement = const Value.absent(),
                Value<bool?> isTrue = const Value.absent(),
                Value<String?> correctAnswer = const Value.absent(),
                Value<String?> explanation = const Value.absent(),
                Value<String?> term = const Value.absent(),
                Value<String?> translation = const Value.absent(),
                Value<String?> exampleSentence = const Value.absent(),
                Value<int> difficulty = const Value.absent(),
                Value<String?> sourceName = const Value.absent(),
                Value<String?> sourceUrl = const Value.absent(),
                Value<bool> verified = const Value.absent(),
                Value<bool> inOfflinePack = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
                Value<DateTime?> createdAt = const Value.absent(),
                Value<DateTime?> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ContentItemsCompanion.insert(
                id: id,
                topicCode: topicCode,
                type: type,
                title: title,
                body: body,
                statement: statement,
                isTrue: isTrue,
                correctAnswer: correctAnswer,
                explanation: explanation,
                term: term,
                translation: translation,
                exampleSentence: exampleSentence,
                difficulty: difficulty,
                sourceName: sourceName,
                sourceUrl: sourceUrl,
                verified: verified,
                inOfflinePack: inOfflinePack,
                isActive: isActive,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$ContentItemsTable, ContentItemRow>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $ContentItemsTable,
                    ContentItemRow
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ContentItemsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ContentItemsTable,
      ContentItemRow,
      $$ContentItemsTableFilterComposer,
      $$ContentItemsTableOrderingComposer,
      $$ContentItemsTableAnnotationComposer,
      $$ContentItemsTableCreateCompanionBuilder,
      $$ContentItemsTableUpdateCompanionBuilder,
      (
        ContentItemRow,
        BaseReferences<_$AppDatabase, $ContentItemsTable, ContentItemRow>,
      ),
      ContentItemRow,
      PrefetchHooks Function()
    >;
typedef $$EssayPromptsTableCreateCompanionBuilder =
    EssayPromptsCompanion Function({
      required String id,
      Value<String?> topicCode,
      required String prompt,
      Value<int> rowid,
    });
typedef $$EssayPromptsTableUpdateCompanionBuilder =
    EssayPromptsCompanion Function({
      Value<String> id,
      Value<String?> topicCode,
      Value<String> prompt,
      Value<int> rowid,
    });

class $$EssayPromptsTableFilterComposer
    extends Composer<_$AppDatabase, $EssayPromptsTable> {
  $$EssayPromptsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get topicCode => $composableBuilder(
    column: $table.topicCode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get prompt => $composableBuilder(
    column: $table.prompt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$EssayPromptsTableOrderingComposer
    extends Composer<_$AppDatabase, $EssayPromptsTable> {
  $$EssayPromptsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get topicCode => $composableBuilder(
    column: $table.topicCode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get prompt => $composableBuilder(
    column: $table.prompt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$EssayPromptsTableAnnotationComposer
    extends Composer<_$AppDatabase, $EssayPromptsTable> {
  $$EssayPromptsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get topicCode =>
      $composableBuilder(column: $table.topicCode, builder: (column) => column);

  GeneratedColumn<String> get prompt =>
      $composableBuilder(column: $table.prompt, builder: (column) => column);
}

class $$EssayPromptsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $EssayPromptsTable,
          EssayPromptRow,
          $$EssayPromptsTableFilterComposer,
          $$EssayPromptsTableOrderingComposer,
          $$EssayPromptsTableAnnotationComposer,
          $$EssayPromptsTableCreateCompanionBuilder,
          $$EssayPromptsTableUpdateCompanionBuilder,
          (
            EssayPromptRow,
            BaseReferences<_$AppDatabase, $EssayPromptsTable, EssayPromptRow>,
          ),
          EssayPromptRow,
          PrefetchHooks Function()
        > {
  $$EssayPromptsTableTableManager(_$AppDatabase db, $EssayPromptsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$EssayPromptsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$EssayPromptsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$EssayPromptsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String?> topicCode = const Value.absent(),
                Value<String> prompt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => EssayPromptsCompanion(
                id: id,
                topicCode: topicCode,
                prompt: prompt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                Value<String?> topicCode = const Value.absent(),
                required String prompt,
                Value<int> rowid = const Value.absent(),
              }) => EssayPromptsCompanion.insert(
                id: id,
                topicCode: topicCode,
                prompt: prompt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$EssayPromptsTable, EssayPromptRow>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $EssayPromptsTable,
                    EssayPromptRow
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$EssayPromptsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $EssayPromptsTable,
      EssayPromptRow,
      $$EssayPromptsTableFilterComposer,
      $$EssayPromptsTableOrderingComposer,
      $$EssayPromptsTableAnnotationComposer,
      $$EssayPromptsTableCreateCompanionBuilder,
      $$EssayPromptsTableUpdateCompanionBuilder,
      (
        EssayPromptRow,
        BaseReferences<_$AppDatabase, $EssayPromptsTable, EssayPromptRow>,
      ),
      EssayPromptRow,
      PrefetchHooks Function()
    >;
typedef $$UserProgressTableCreateCompanionBuilder =
    UserProgressCompanion Function({
      required String itemId,
      Value<int> seenCount,
      Value<int> answeredCorrect,
      Value<int> answeredWrong,
      Value<bool?> lastAnswerCorrect,
      Value<DateTime?> lastSeenAt,
      Value<bool> saved,
      Value<DateTime?> savedUpdatedAt,
      Value<bool> reported,
      Value<DateTime?> updatedAt,
      Value<int> rowid,
    });
typedef $$UserProgressTableUpdateCompanionBuilder =
    UserProgressCompanion Function({
      Value<String> itemId,
      Value<int> seenCount,
      Value<int> answeredCorrect,
      Value<int> answeredWrong,
      Value<bool?> lastAnswerCorrect,
      Value<DateTime?> lastSeenAt,
      Value<bool> saved,
      Value<DateTime?> savedUpdatedAt,
      Value<bool> reported,
      Value<DateTime?> updatedAt,
      Value<int> rowid,
    });

class $$UserProgressTableFilterComposer
    extends Composer<_$AppDatabase, $UserProgressTable> {
  $$UserProgressTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get itemId => $composableBuilder(
    column: $table.itemId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get seenCount => $composableBuilder(
    column: $table.seenCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get answeredCorrect => $composableBuilder(
    column: $table.answeredCorrect,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get answeredWrong => $composableBuilder(
    column: $table.answeredWrong,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get lastAnswerCorrect => $composableBuilder(
    column: $table.lastAnswerCorrect,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastSeenAt => $composableBuilder(
    column: $table.lastSeenAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get saved => $composableBuilder(
    column: $table.saved,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get savedUpdatedAt => $composableBuilder(
    column: $table.savedUpdatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get reported => $composableBuilder(
    column: $table.reported,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$UserProgressTableOrderingComposer
    extends Composer<_$AppDatabase, $UserProgressTable> {
  $$UserProgressTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get itemId => $composableBuilder(
    column: $table.itemId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get seenCount => $composableBuilder(
    column: $table.seenCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get answeredCorrect => $composableBuilder(
    column: $table.answeredCorrect,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get answeredWrong => $composableBuilder(
    column: $table.answeredWrong,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get lastAnswerCorrect => $composableBuilder(
    column: $table.lastAnswerCorrect,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastSeenAt => $composableBuilder(
    column: $table.lastSeenAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get saved => $composableBuilder(
    column: $table.saved,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get savedUpdatedAt => $composableBuilder(
    column: $table.savedUpdatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get reported => $composableBuilder(
    column: $table.reported,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$UserProgressTableAnnotationComposer
    extends Composer<_$AppDatabase, $UserProgressTable> {
  $$UserProgressTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get itemId =>
      $composableBuilder(column: $table.itemId, builder: (column) => column);

  GeneratedColumn<int> get seenCount =>
      $composableBuilder(column: $table.seenCount, builder: (column) => column);

  GeneratedColumn<int> get answeredCorrect => $composableBuilder(
    column: $table.answeredCorrect,
    builder: (column) => column,
  );

  GeneratedColumn<int> get answeredWrong => $composableBuilder(
    column: $table.answeredWrong,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get lastAnswerCorrect => $composableBuilder(
    column: $table.lastAnswerCorrect,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get lastSeenAt => $composableBuilder(
    column: $table.lastSeenAt,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get saved =>
      $composableBuilder(column: $table.saved, builder: (column) => column);

  GeneratedColumn<DateTime> get savedUpdatedAt => $composableBuilder(
    column: $table.savedUpdatedAt,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get reported =>
      $composableBuilder(column: $table.reported, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$UserProgressTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $UserProgressTable,
          ProgressRow,
          $$UserProgressTableFilterComposer,
          $$UserProgressTableOrderingComposer,
          $$UserProgressTableAnnotationComposer,
          $$UserProgressTableCreateCompanionBuilder,
          $$UserProgressTableUpdateCompanionBuilder,
          (
            ProgressRow,
            BaseReferences<_$AppDatabase, $UserProgressTable, ProgressRow>,
          ),
          ProgressRow,
          PrefetchHooks Function()
        > {
  $$UserProgressTableTableManager(_$AppDatabase db, $UserProgressTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$UserProgressTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$UserProgressTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$UserProgressTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> itemId = const Value.absent(),
                Value<int> seenCount = const Value.absent(),
                Value<int> answeredCorrect = const Value.absent(),
                Value<int> answeredWrong = const Value.absent(),
                Value<bool?> lastAnswerCorrect = const Value.absent(),
                Value<DateTime?> lastSeenAt = const Value.absent(),
                Value<bool> saved = const Value.absent(),
                Value<DateTime?> savedUpdatedAt = const Value.absent(),
                Value<bool> reported = const Value.absent(),
                Value<DateTime?> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => UserProgressCompanion(
                itemId: itemId,
                seenCount: seenCount,
                answeredCorrect: answeredCorrect,
                answeredWrong: answeredWrong,
                lastAnswerCorrect: lastAnswerCorrect,
                lastSeenAt: lastSeenAt,
                saved: saved,
                savedUpdatedAt: savedUpdatedAt,
                reported: reported,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String itemId,
                Value<int> seenCount = const Value.absent(),
                Value<int> answeredCorrect = const Value.absent(),
                Value<int> answeredWrong = const Value.absent(),
                Value<bool?> lastAnswerCorrect = const Value.absent(),
                Value<DateTime?> lastSeenAt = const Value.absent(),
                Value<bool> saved = const Value.absent(),
                Value<DateTime?> savedUpdatedAt = const Value.absent(),
                Value<bool> reported = const Value.absent(),
                Value<DateTime?> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => UserProgressCompanion.insert(
                itemId: itemId,
                seenCount: seenCount,
                answeredCorrect: answeredCorrect,
                answeredWrong: answeredWrong,
                lastAnswerCorrect: lastAnswerCorrect,
                lastSeenAt: lastSeenAt,
                saved: saved,
                savedUpdatedAt: savedUpdatedAt,
                reported: reported,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$UserProgressTable, ProgressRow>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $UserProgressTable,
                    ProgressRow
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$UserProgressTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $UserProgressTable,
      ProgressRow,
      $$UserProgressTableFilterComposer,
      $$UserProgressTableOrderingComposer,
      $$UserProgressTableAnnotationComposer,
      $$UserProgressTableCreateCompanionBuilder,
      $$UserProgressTableUpdateCompanionBuilder,
      (
        ProgressRow,
        BaseReferences<_$AppDatabase, $UserProgressTable, ProgressRow>,
      ),
      ProgressRow,
      PrefetchHooks Function()
    >;
typedef $$DailyActivityEntriesTableCreateCompanionBuilder =
    DailyActivityEntriesCompanion Function({
      required String day,
      required String topics,
      Value<int> itemsCompleted,
      Value<int> rowid,
    });
typedef $$DailyActivityEntriesTableUpdateCompanionBuilder =
    DailyActivityEntriesCompanion Function({
      Value<String> day,
      Value<String> topics,
      Value<int> itemsCompleted,
      Value<int> rowid,
    });

class $$DailyActivityEntriesTableFilterComposer
    extends Composer<_$AppDatabase, $DailyActivityEntriesTable> {
  $$DailyActivityEntriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get day => $composableBuilder(
    column: $table.day,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get topics => $composableBuilder(
    column: $table.topics,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get itemsCompleted => $composableBuilder(
    column: $table.itemsCompleted,
    builder: (column) => ColumnFilters(column),
  );
}

class $$DailyActivityEntriesTableOrderingComposer
    extends Composer<_$AppDatabase, $DailyActivityEntriesTable> {
  $$DailyActivityEntriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get day => $composableBuilder(
    column: $table.day,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get topics => $composableBuilder(
    column: $table.topics,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get itemsCompleted => $composableBuilder(
    column: $table.itemsCompleted,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$DailyActivityEntriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $DailyActivityEntriesTable> {
  $$DailyActivityEntriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get day =>
      $composableBuilder(column: $table.day, builder: (column) => column);

  GeneratedColumn<String> get topics =>
      $composableBuilder(column: $table.topics, builder: (column) => column);

  GeneratedColumn<int> get itemsCompleted => $composableBuilder(
    column: $table.itemsCompleted,
    builder: (column) => column,
  );
}

class $$DailyActivityEntriesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $DailyActivityEntriesTable,
          DailyActivityRow,
          $$DailyActivityEntriesTableFilterComposer,
          $$DailyActivityEntriesTableOrderingComposer,
          $$DailyActivityEntriesTableAnnotationComposer,
          $$DailyActivityEntriesTableCreateCompanionBuilder,
          $$DailyActivityEntriesTableUpdateCompanionBuilder,
          (
            DailyActivityRow,
            BaseReferences<
              _$AppDatabase,
              $DailyActivityEntriesTable,
              DailyActivityRow
            >,
          ),
          DailyActivityRow,
          PrefetchHooks Function()
        > {
  $$DailyActivityEntriesTableTableManager(
    _$AppDatabase db,
    $DailyActivityEntriesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DailyActivityEntriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DailyActivityEntriesTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$DailyActivityEntriesTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> day = const Value.absent(),
                Value<String> topics = const Value.absent(),
                Value<int> itemsCompleted = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => DailyActivityEntriesCompanion(
                day: day,
                topics: topics,
                itemsCompleted: itemsCompleted,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String day,
                required String topics,
                Value<int> itemsCompleted = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => DailyActivityEntriesCompanion.insert(
                day: day,
                topics: topics,
                itemsCompleted: itemsCompleted,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$DailyActivityEntriesTable, DailyActivityRow>(
                    table,
                  ),
                  BaseReferences<
                    _$AppDatabase,
                    $DailyActivityEntriesTable,
                    DailyActivityRow
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$DailyActivityEntriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $DailyActivityEntriesTable,
      DailyActivityRow,
      $$DailyActivityEntriesTableFilterComposer,
      $$DailyActivityEntriesTableOrderingComposer,
      $$DailyActivityEntriesTableAnnotationComposer,
      $$DailyActivityEntriesTableCreateCompanionBuilder,
      $$DailyActivityEntriesTableUpdateCompanionBuilder,
      (
        DailyActivityRow,
        BaseReferences<
          _$AppDatabase,
          $DailyActivityEntriesTable,
          DailyActivityRow
        >,
      ),
      DailyActivityRow,
      PrefetchHooks Function()
    >;
typedef $$EssaysTableCreateCompanionBuilder = EssaysCompanion Function({
  required String id,
  required String prompt,
  Value<String?> localImagePath,
  Value<String?> imagePath,
  Value<String?> extractedText,
  Value<int?> scoreTotal,
  Value<String?> resultJson,
  required String status,
  Value<String?> errorMessage,
  required DateTime createdAt,
  Value<int> rowid,
});
typedef $$EssaysTableUpdateCompanionBuilder = EssaysCompanion Function({
  Value<String> id,
  Value<String> prompt,
  Value<String?> localImagePath,
  Value<String?> imagePath,
  Value<String?> extractedText,
  Value<int?> scoreTotal,
  Value<String?> resultJson,
  Value<String> status,
  Value<String?> errorMessage,
  Value<DateTime> createdAt,
  Value<int> rowid,
});

class $$EssaysTableFilterComposer
    extends Composer<_$AppDatabase, $EssaysTable> {
  $$EssaysTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get prompt => $composableBuilder(
    column: $table.prompt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get localImagePath => $composableBuilder(
    column: $table.localImagePath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get imagePath => $composableBuilder(
    column: $table.imagePath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get extractedText => $composableBuilder(
    column: $table.extractedText,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get scoreTotal => $composableBuilder(
    column: $table.scoreTotal,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get resultJson => $composableBuilder(
    column: $table.resultJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get errorMessage => $composableBuilder(
    column: $table.errorMessage,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$EssaysTableOrderingComposer
    extends Composer<_$AppDatabase, $EssaysTable> {
  $$EssaysTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get prompt => $composableBuilder(
    column: $table.prompt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get localImagePath => $composableBuilder(
    column: $table.localImagePath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get imagePath => $composableBuilder(
    column: $table.imagePath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get extractedText => $composableBuilder(
    column: $table.extractedText,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get scoreTotal => $composableBuilder(
    column: $table.scoreTotal,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get resultJson => $composableBuilder(
    column: $table.resultJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get errorMessage => $composableBuilder(
    column: $table.errorMessage,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$EssaysTableAnnotationComposer
    extends Composer<_$AppDatabase, $EssaysTable> {
  $$EssaysTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get prompt =>
      $composableBuilder(column: $table.prompt, builder: (column) => column);

  GeneratedColumn<String> get localImagePath => $composableBuilder(
    column: $table.localImagePath,
    builder: (column) => column,
  );

  GeneratedColumn<String> get imagePath =>
      $composableBuilder(column: $table.imagePath, builder: (column) => column);

  GeneratedColumn<String> get extractedText => $composableBuilder(
    column: $table.extractedText,
    builder: (column) => column,
  );

  GeneratedColumn<int> get scoreTotal => $composableBuilder(
    column: $table.scoreTotal,
    builder: (column) => column,
  );

  GeneratedColumn<String> get resultJson => $composableBuilder(
    column: $table.resultJson,
    builder: (column) => column,
  );

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get errorMessage => $composableBuilder(
    column: $table.errorMessage,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$EssaysTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $EssaysTable,
          EssayRow,
          $$EssaysTableFilterComposer,
          $$EssaysTableOrderingComposer,
          $$EssaysTableAnnotationComposer,
          $$EssaysTableCreateCompanionBuilder,
          $$EssaysTableUpdateCompanionBuilder,
          (EssayRow, BaseReferences<_$AppDatabase, $EssaysTable, EssayRow>),
          EssayRow,
          PrefetchHooks Function()
        > {
  $$EssaysTableTableManager(_$AppDatabase db, $EssaysTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$EssaysTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$EssaysTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$EssaysTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> prompt = const Value.absent(),
                Value<String?> localImagePath = const Value.absent(),
                Value<String?> imagePath = const Value.absent(),
                Value<String?> extractedText = const Value.absent(),
                Value<int?> scoreTotal = const Value.absent(),
                Value<String?> resultJson = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<String?> errorMessage = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => EssaysCompanion(
                id: id,
                prompt: prompt,
                localImagePath: localImagePath,
                imagePath: imagePath,
                extractedText: extractedText,
                scoreTotal: scoreTotal,
                resultJson: resultJson,
                status: status,
                errorMessage: errorMessage,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String prompt,
                Value<String?> localImagePath = const Value.absent(),
                Value<String?> imagePath = const Value.absent(),
                Value<String?> extractedText = const Value.absent(),
                Value<int?> scoreTotal = const Value.absent(),
                Value<String?> resultJson = const Value.absent(),
                required String status,
                Value<String?> errorMessage = const Value.absent(),
                required DateTime createdAt,
                Value<int> rowid = const Value.absent(),
              }) => EssaysCompanion.insert(
                id: id,
                prompt: prompt,
                localImagePath: localImagePath,
                imagePath: imagePath,
                extractedText: extractedText,
                scoreTotal: scoreTotal,
                resultJson: resultJson,
                status: status,
                errorMessage: errorMessage,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$EssaysTable, EssayRow>(table),
                  BaseReferences<_$AppDatabase, $EssaysTable, EssayRow>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$EssaysTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $EssaysTable,
      EssayRow,
      $$EssaysTableFilterComposer,
      $$EssaysTableOrderingComposer,
      $$EssaysTableAnnotationComposer,
      $$EssaysTableCreateCompanionBuilder,
      $$EssaysTableUpdateCompanionBuilder,
      (EssayRow, BaseReferences<_$AppDatabase, $EssaysTable, EssayRow>),
      EssayRow,
      PrefetchHooks Function()
    >;
typedef $$SettingsTableCreateCompanionBuilder = SettingsCompanion Function({
  required String key,
  required String value,
  Value<int> rowid,
});
typedef $$SettingsTableUpdateCompanionBuilder = SettingsCompanion Function({
  Value<String> key,
  Value<String> value,
  Value<int> rowid,
});

class $$SettingsTableFilterComposer
    extends Composer<_$AppDatabase, $SettingsTable> {
  $$SettingsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SettingsTableOrderingComposer
    extends Composer<_$AppDatabase, $SettingsTable> {
  $$SettingsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SettingsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SettingsTable> {
  $$SettingsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get key =>
      $composableBuilder(column: $table.key, builder: (column) => column);

  GeneratedColumn<String> get value =>
      $composableBuilder(column: $table.value, builder: (column) => column);
}

class $$SettingsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SettingsTable,
          SettingRow,
          $$SettingsTableFilterComposer,
          $$SettingsTableOrderingComposer,
          $$SettingsTableAnnotationComposer,
          $$SettingsTableCreateCompanionBuilder,
          $$SettingsTableUpdateCompanionBuilder,
          (
            SettingRow,
            BaseReferences<_$AppDatabase, $SettingsTable, SettingRow>,
          ),
          SettingRow,
          PrefetchHooks Function()
        > {
  $$SettingsTableTableManager(_$AppDatabase db, $SettingsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SettingsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SettingsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SettingsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> key = const Value.absent(),
            Value<String> value = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) => SettingsCompanion(key: key, value: value, rowid: rowid),
          createCompanionCallback: ({
            required String key,
            required String value,
            Value<int> rowid = const Value.absent(),
          }) => SettingsCompanion.insert(key: key, value: value, rowid: rowid),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$SettingsTable, SettingRow>(table),
                  BaseReferences<_$AppDatabase, $SettingsTable, SettingRow>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SettingsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SettingsTable,
      SettingRow,
      $$SettingsTableFilterComposer,
      $$SettingsTableOrderingComposer,
      $$SettingsTableAnnotationComposer,
      $$SettingsTableCreateCompanionBuilder,
      $$SettingsTableUpdateCompanionBuilder,
      (SettingRow, BaseReferences<_$AppDatabase, $SettingsTable, SettingRow>),
      SettingRow,
      PrefetchHooks Function()
    >;
typedef $$SyncQueueTableCreateCompanionBuilder = SyncQueueCompanion Function({
  Value<int> id,
  required String entity,
  required String entityKey,
  required String payloadJson,
  required DateTime createdAt,
  Value<int> attempts,
});
typedef $$SyncQueueTableUpdateCompanionBuilder = SyncQueueCompanion Function({
  Value<int> id,
  Value<String> entity,
  Value<String> entityKey,
  Value<String> payloadJson,
  Value<DateTime> createdAt,
  Value<int> attempts,
});

class $$SyncQueueTableFilterComposer
    extends Composer<_$AppDatabase, $SyncQueueTable> {
  $$SyncQueueTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get entity => $composableBuilder(
    column: $table.entity,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get entityKey => $composableBuilder(
    column: $table.entityKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get payloadJson => $composableBuilder(
    column: $table.payloadJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get attempts => $composableBuilder(
    column: $table.attempts,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SyncQueueTableOrderingComposer
    extends Composer<_$AppDatabase, $SyncQueueTable> {
  $$SyncQueueTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get entity => $composableBuilder(
    column: $table.entity,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get entityKey => $composableBuilder(
    column: $table.entityKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get payloadJson => $composableBuilder(
    column: $table.payloadJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get attempts => $composableBuilder(
    column: $table.attempts,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SyncQueueTableAnnotationComposer
    extends Composer<_$AppDatabase, $SyncQueueTable> {
  $$SyncQueueTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get entity =>
      $composableBuilder(column: $table.entity, builder: (column) => column);

  GeneratedColumn<String> get entityKey =>
      $composableBuilder(column: $table.entityKey, builder: (column) => column);

  GeneratedColumn<String> get payloadJson => $composableBuilder(
    column: $table.payloadJson,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get attempts =>
      $composableBuilder(column: $table.attempts, builder: (column) => column);
}

class $$SyncQueueTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SyncQueueTable,
          SyncQueueRow,
          $$SyncQueueTableFilterComposer,
          $$SyncQueueTableOrderingComposer,
          $$SyncQueueTableAnnotationComposer,
          $$SyncQueueTableCreateCompanionBuilder,
          $$SyncQueueTableUpdateCompanionBuilder,
          (
            SyncQueueRow,
            BaseReferences<_$AppDatabase, $SyncQueueTable, SyncQueueRow>,
          ),
          SyncQueueRow,
          PrefetchHooks Function()
        > {
  $$SyncQueueTableTableManager(_$AppDatabase db, $SyncQueueTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SyncQueueTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SyncQueueTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SyncQueueTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> entity = const Value.absent(),
                Value<String> entityKey = const Value.absent(),
                Value<String> payloadJson = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> attempts = const Value.absent(),
              }) => SyncQueueCompanion(
                id: id,
                entity: entity,
                entityKey: entityKey,
                payloadJson: payloadJson,
                createdAt: createdAt,
                attempts: attempts,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String entity,
                required String entityKey,
                required String payloadJson,
                required DateTime createdAt,
                Value<int> attempts = const Value.absent(),
              }) => SyncQueueCompanion.insert(
                id: id,
                entity: entity,
                entityKey: entityKey,
                payloadJson: payloadJson,
                createdAt: createdAt,
                attempts: attempts,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$SyncQueueTable, SyncQueueRow>(table),
                  BaseReferences<_$AppDatabase, $SyncQueueTable, SyncQueueRow>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SyncQueueTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SyncQueueTable,
      SyncQueueRow,
      $$SyncQueueTableFilterComposer,
      $$SyncQueueTableOrderingComposer,
      $$SyncQueueTableAnnotationComposer,
      $$SyncQueueTableCreateCompanionBuilder,
      $$SyncQueueTableUpdateCompanionBuilder,
      (
        SyncQueueRow,
        BaseReferences<_$AppDatabase, $SyncQueueTable, SyncQueueRow>,
      ),
      SyncQueueRow,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$TopicsTableTableManager get topics =>
      $$TopicsTableTableManager(_db, _db.topics);
  $$ContentItemsTableTableManager get contentItems =>
      $$ContentItemsTableTableManager(_db, _db.contentItems);
  $$EssayPromptsTableTableManager get essayPrompts =>
      $$EssayPromptsTableTableManager(_db, _db.essayPrompts);
  $$UserProgressTableTableManager get userProgress =>
      $$UserProgressTableTableManager(_db, _db.userProgress);
  $$DailyActivityEntriesTableTableManager get dailyActivityEntries =>
      $$DailyActivityEntriesTableTableManager(_db, _db.dailyActivityEntries);
  $$EssaysTableTableManager get essays =>
      $$EssaysTableTableManager(_db, _db.essays);
  $$SettingsTableTableManager get settings =>
      $$SettingsTableTableManager(_db, _db.settings);
  $$SyncQueueTableTableManager get syncQueue =>
      $$SyncQueueTableTableManager(_db, _db.syncQueue);
}

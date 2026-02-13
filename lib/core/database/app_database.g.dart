// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $TasksTable extends Tasks with TableInfo<$TasksTable, TaskDbModel> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TasksTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _goalIdMeta = const VerificationMeta('goalId');
  @override
  late final GeneratedColumn<int> goalId = GeneratedColumn<int>(
    'goal_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _goalTitleMeta = const VerificationMeta(
    'goalTitle',
  );
  @override
  late final GeneratedColumn<String> goalTitle = GeneratedColumn<String>(
    'goal_title',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
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
  static const VerificationMeta _descriptionMeta = const VerificationMeta(
    'description',
  );
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _orderMeta = const VerificationMeta('order');
  @override
  late final GeneratedColumn<int> order = GeneratedColumn<int>(
    'order',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  late final GeneratedColumnWithTypeConverter<DateTime, int> scheduledAt =
      GeneratedColumn<int>(
        'scheduled_at',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: true,
      ).withConverter<DateTime>($TasksTable.$converterscheduledAt);
  @override
  late final GeneratedColumnWithTypeConverter<DateTime, int> endAt =
      GeneratedColumn<int>(
        'end_at',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: true,
      ).withConverter<DateTime>($TasksTable.$converterendAt);
  static const VerificationMeta _durationMinutesMeta = const VerificationMeta(
    'durationMinutes',
  );
  @override
  late final GeneratedColumn<int> durationMinutes = GeneratedColumn<int>(
    'duration_minutes',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
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
  static const VerificationMeta _isLockedMeta = const VerificationMeta(
    'isLocked',
  );
  @override
  late final GeneratedColumn<bool> isLocked = GeneratedColumn<bool>(
    'is_locked',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_locked" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  late final GeneratedColumnWithTypeConverter<DateTime?, int> completedAt =
      GeneratedColumn<int>(
        'completed_at',
        aliasedName,
        true,
        type: DriftSqlType.int,
        requiredDuringInsert: false,
      ).withConverter<DateTime?>($TasksTable.$convertercompletedAtn);
  @override
  late final GeneratedColumnWithTypeConverter<DateTime, int> cachedAt =
      GeneratedColumn<int>(
        'cached_at',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: true,
      ).withConverter<DateTime>($TasksTable.$convertercachedAt);
  @override
  List<GeneratedColumn> get $columns => [
    id,
    goalId,
    goalTitle,
    title,
    description,
    order,
    scheduledAt,
    endAt,
    durationMinutes,
    status,
    isLocked,
    notes,
    completedAt,
    cachedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'tasks';
  @override
  VerificationContext validateIntegrity(
    Insertable<TaskDbModel> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('goal_id')) {
      context.handle(
        _goalIdMeta,
        goalId.isAcceptableOrUnknown(data['goal_id']!, _goalIdMeta),
      );
    } else if (isInserting) {
      context.missing(_goalIdMeta);
    }
    if (data.containsKey('goal_title')) {
      context.handle(
        _goalTitleMeta,
        goalTitle.isAcceptableOrUnknown(data['goal_title']!, _goalTitleMeta),
      );
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
        _descriptionMeta,
        description.isAcceptableOrUnknown(
          data['description']!,
          _descriptionMeta,
        ),
      );
    }
    if (data.containsKey('order')) {
      context.handle(
        _orderMeta,
        order.isAcceptableOrUnknown(data['order']!, _orderMeta),
      );
    }
    if (data.containsKey('duration_minutes')) {
      context.handle(
        _durationMinutesMeta,
        durationMinutes.isAcceptableOrUnknown(
          data['duration_minutes']!,
          _durationMinutesMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_durationMinutesMeta);
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    if (data.containsKey('is_locked')) {
      context.handle(
        _isLockedMeta,
        isLocked.isAcceptableOrUnknown(data['is_locked']!, _isLockedMeta),
      );
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  TaskDbModel map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TaskDbModel(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      goalId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}goal_id'],
      )!,
      goalTitle: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}goal_title'],
      ),
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      ),
      order: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}order'],
      )!,
      scheduledAt: $TasksTable.$converterscheduledAt.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}scheduled_at'],
        )!,
      ),
      endAt: $TasksTable.$converterendAt.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}end_at'],
        )!,
      ),
      durationMinutes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}duration_minutes'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      isLocked: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_locked'],
      )!,
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
      completedAt: $TasksTable.$convertercompletedAtn.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}completed_at'],
        ),
      ),
      cachedAt: $TasksTable.$convertercachedAt.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}cached_at'],
        )!,
      ),
    );
  }

  @override
  $TasksTable createAlias(String alias) {
    return $TasksTable(attachedDatabase, alias);
  }

  static TypeConverter<DateTime, int> $converterscheduledAt =
      const DateTimeConverter();
  static TypeConverter<DateTime, int> $converterendAt =
      const DateTimeConverter();
  static TypeConverter<DateTime, int> $convertercompletedAt =
      const DateTimeConverter();
  static TypeConverter<DateTime?, int?> $convertercompletedAtn =
      NullAwareTypeConverter.wrap($convertercompletedAt);
  static TypeConverter<DateTime, int> $convertercachedAt =
      const DateTimeConverter();
}

class TaskDbModel extends DataClass implements Insertable<TaskDbModel> {
  /// Unique identifier (primary key).
  final int id;

  /// Foreign key to the goal this task belongs to.
  final int goalId;

  /// Title of the goal (denormalized for display).
  final String? goalTitle;

  /// Task title.
  final String title;

  /// Optional description.
  final String? description;

  /// Display order within the goal.
  final int order;

  /// When the task is scheduled (Unix timestamp).
  final DateTime scheduledAt;

  /// When the task ends (Unix timestamp).
  final DateTime endAt;

  /// Duration in minutes.
  final int durationMinutes;

  /// Status: scheduled, completed, skipped.
  final String status;

  /// Whether the task is locked.
  final bool isLocked;

  /// Optional notes.
  final String? notes;

  /// When the task was completed (Unix timestamp, nullable).
  final DateTime? completedAt;

  /// When this record was cached (for cache invalidation).
  final DateTime cachedAt;
  const TaskDbModel({
    required this.id,
    required this.goalId,
    this.goalTitle,
    required this.title,
    this.description,
    required this.order,
    required this.scheduledAt,
    required this.endAt,
    required this.durationMinutes,
    required this.status,
    required this.isLocked,
    this.notes,
    this.completedAt,
    required this.cachedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['goal_id'] = Variable<int>(goalId);
    if (!nullToAbsent || goalTitle != null) {
      map['goal_title'] = Variable<String>(goalTitle);
    }
    map['title'] = Variable<String>(title);
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    map['order'] = Variable<int>(order);
    {
      map['scheduled_at'] = Variable<int>(
        $TasksTable.$converterscheduledAt.toSql(scheduledAt),
      );
    }
    {
      map['end_at'] = Variable<int>($TasksTable.$converterendAt.toSql(endAt));
    }
    map['duration_minutes'] = Variable<int>(durationMinutes);
    map['status'] = Variable<String>(status);
    map['is_locked'] = Variable<bool>(isLocked);
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    if (!nullToAbsent || completedAt != null) {
      map['completed_at'] = Variable<int>(
        $TasksTable.$convertercompletedAtn.toSql(completedAt),
      );
    }
    {
      map['cached_at'] = Variable<int>(
        $TasksTable.$convertercachedAt.toSql(cachedAt),
      );
    }
    return map;
  }

  TasksCompanion toCompanion(bool nullToAbsent) {
    return TasksCompanion(
      id: Value(id),
      goalId: Value(goalId),
      goalTitle: goalTitle == null && nullToAbsent
          ? const Value.absent()
          : Value(goalTitle),
      title: Value(title),
      description: description == null && nullToAbsent
          ? const Value.absent()
          : Value(description),
      order: Value(order),
      scheduledAt: Value(scheduledAt),
      endAt: Value(endAt),
      durationMinutes: Value(durationMinutes),
      status: Value(status),
      isLocked: Value(isLocked),
      notes: notes == null && nullToAbsent
          ? const Value.absent()
          : Value(notes),
      completedAt: completedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(completedAt),
      cachedAt: Value(cachedAt),
    );
  }

  factory TaskDbModel.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TaskDbModel(
      id: serializer.fromJson<int>(json['id']),
      goalId: serializer.fromJson<int>(json['goalId']),
      goalTitle: serializer.fromJson<String?>(json['goalTitle']),
      title: serializer.fromJson<String>(json['title']),
      description: serializer.fromJson<String?>(json['description']),
      order: serializer.fromJson<int>(json['order']),
      scheduledAt: serializer.fromJson<DateTime>(json['scheduledAt']),
      endAt: serializer.fromJson<DateTime>(json['endAt']),
      durationMinutes: serializer.fromJson<int>(json['durationMinutes']),
      status: serializer.fromJson<String>(json['status']),
      isLocked: serializer.fromJson<bool>(json['isLocked']),
      notes: serializer.fromJson<String?>(json['notes']),
      completedAt: serializer.fromJson<DateTime?>(json['completedAt']),
      cachedAt: serializer.fromJson<DateTime>(json['cachedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'goalId': serializer.toJson<int>(goalId),
      'goalTitle': serializer.toJson<String?>(goalTitle),
      'title': serializer.toJson<String>(title),
      'description': serializer.toJson<String?>(description),
      'order': serializer.toJson<int>(order),
      'scheduledAt': serializer.toJson<DateTime>(scheduledAt),
      'endAt': serializer.toJson<DateTime>(endAt),
      'durationMinutes': serializer.toJson<int>(durationMinutes),
      'status': serializer.toJson<String>(status),
      'isLocked': serializer.toJson<bool>(isLocked),
      'notes': serializer.toJson<String?>(notes),
      'completedAt': serializer.toJson<DateTime?>(completedAt),
      'cachedAt': serializer.toJson<DateTime>(cachedAt),
    };
  }

  TaskDbModel copyWith({
    int? id,
    int? goalId,
    Value<String?> goalTitle = const Value.absent(),
    String? title,
    Value<String?> description = const Value.absent(),
    int? order,
    DateTime? scheduledAt,
    DateTime? endAt,
    int? durationMinutes,
    String? status,
    bool? isLocked,
    Value<String?> notes = const Value.absent(),
    Value<DateTime?> completedAt = const Value.absent(),
    DateTime? cachedAt,
  }) => TaskDbModel(
    id: id ?? this.id,
    goalId: goalId ?? this.goalId,
    goalTitle: goalTitle.present ? goalTitle.value : this.goalTitle,
    title: title ?? this.title,
    description: description.present ? description.value : this.description,
    order: order ?? this.order,
    scheduledAt: scheduledAt ?? this.scheduledAt,
    endAt: endAt ?? this.endAt,
    durationMinutes: durationMinutes ?? this.durationMinutes,
    status: status ?? this.status,
    isLocked: isLocked ?? this.isLocked,
    notes: notes.present ? notes.value : this.notes,
    completedAt: completedAt.present ? completedAt.value : this.completedAt,
    cachedAt: cachedAt ?? this.cachedAt,
  );
  TaskDbModel copyWithCompanion(TasksCompanion data) {
    return TaskDbModel(
      id: data.id.present ? data.id.value : this.id,
      goalId: data.goalId.present ? data.goalId.value : this.goalId,
      goalTitle: data.goalTitle.present ? data.goalTitle.value : this.goalTitle,
      title: data.title.present ? data.title.value : this.title,
      description: data.description.present
          ? data.description.value
          : this.description,
      order: data.order.present ? data.order.value : this.order,
      scheduledAt: data.scheduledAt.present
          ? data.scheduledAt.value
          : this.scheduledAt,
      endAt: data.endAt.present ? data.endAt.value : this.endAt,
      durationMinutes: data.durationMinutes.present
          ? data.durationMinutes.value
          : this.durationMinutes,
      status: data.status.present ? data.status.value : this.status,
      isLocked: data.isLocked.present ? data.isLocked.value : this.isLocked,
      notes: data.notes.present ? data.notes.value : this.notes,
      completedAt: data.completedAt.present
          ? data.completedAt.value
          : this.completedAt,
      cachedAt: data.cachedAt.present ? data.cachedAt.value : this.cachedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TaskDbModel(')
          ..write('id: $id, ')
          ..write('goalId: $goalId, ')
          ..write('goalTitle: $goalTitle, ')
          ..write('title: $title, ')
          ..write('description: $description, ')
          ..write('order: $order, ')
          ..write('scheduledAt: $scheduledAt, ')
          ..write('endAt: $endAt, ')
          ..write('durationMinutes: $durationMinutes, ')
          ..write('status: $status, ')
          ..write('isLocked: $isLocked, ')
          ..write('notes: $notes, ')
          ..write('completedAt: $completedAt, ')
          ..write('cachedAt: $cachedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    goalId,
    goalTitle,
    title,
    description,
    order,
    scheduledAt,
    endAt,
    durationMinutes,
    status,
    isLocked,
    notes,
    completedAt,
    cachedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TaskDbModel &&
          other.id == this.id &&
          other.goalId == this.goalId &&
          other.goalTitle == this.goalTitle &&
          other.title == this.title &&
          other.description == this.description &&
          other.order == this.order &&
          other.scheduledAt == this.scheduledAt &&
          other.endAt == this.endAt &&
          other.durationMinutes == this.durationMinutes &&
          other.status == this.status &&
          other.isLocked == this.isLocked &&
          other.notes == this.notes &&
          other.completedAt == this.completedAt &&
          other.cachedAt == this.cachedAt);
}

class TasksCompanion extends UpdateCompanion<TaskDbModel> {
  final Value<int> id;
  final Value<int> goalId;
  final Value<String?> goalTitle;
  final Value<String> title;
  final Value<String?> description;
  final Value<int> order;
  final Value<DateTime> scheduledAt;
  final Value<DateTime> endAt;
  final Value<int> durationMinutes;
  final Value<String> status;
  final Value<bool> isLocked;
  final Value<String?> notes;
  final Value<DateTime?> completedAt;
  final Value<DateTime> cachedAt;
  const TasksCompanion({
    this.id = const Value.absent(),
    this.goalId = const Value.absent(),
    this.goalTitle = const Value.absent(),
    this.title = const Value.absent(),
    this.description = const Value.absent(),
    this.order = const Value.absent(),
    this.scheduledAt = const Value.absent(),
    this.endAt = const Value.absent(),
    this.durationMinutes = const Value.absent(),
    this.status = const Value.absent(),
    this.isLocked = const Value.absent(),
    this.notes = const Value.absent(),
    this.completedAt = const Value.absent(),
    this.cachedAt = const Value.absent(),
  });
  TasksCompanion.insert({
    this.id = const Value.absent(),
    required int goalId,
    this.goalTitle = const Value.absent(),
    required String title,
    this.description = const Value.absent(),
    this.order = const Value.absent(),
    required DateTime scheduledAt,
    required DateTime endAt,
    required int durationMinutes,
    required String status,
    this.isLocked = const Value.absent(),
    this.notes = const Value.absent(),
    this.completedAt = const Value.absent(),
    required DateTime cachedAt,
  }) : goalId = Value(goalId),
       title = Value(title),
       scheduledAt = Value(scheduledAt),
       endAt = Value(endAt),
       durationMinutes = Value(durationMinutes),
       status = Value(status),
       cachedAt = Value(cachedAt);
  static Insertable<TaskDbModel> custom({
    Expression<int>? id,
    Expression<int>? goalId,
    Expression<String>? goalTitle,
    Expression<String>? title,
    Expression<String>? description,
    Expression<int>? order,
    Expression<int>? scheduledAt,
    Expression<int>? endAt,
    Expression<int>? durationMinutes,
    Expression<String>? status,
    Expression<bool>? isLocked,
    Expression<String>? notes,
    Expression<int>? completedAt,
    Expression<int>? cachedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (goalId != null) 'goal_id': goalId,
      if (goalTitle != null) 'goal_title': goalTitle,
      if (title != null) 'title': title,
      if (description != null) 'description': description,
      if (order != null) 'order': order,
      if (scheduledAt != null) 'scheduled_at': scheduledAt,
      if (endAt != null) 'end_at': endAt,
      if (durationMinutes != null) 'duration_minutes': durationMinutes,
      if (status != null) 'status': status,
      if (isLocked != null) 'is_locked': isLocked,
      if (notes != null) 'notes': notes,
      if (completedAt != null) 'completed_at': completedAt,
      if (cachedAt != null) 'cached_at': cachedAt,
    });
  }

  TasksCompanion copyWith({
    Value<int>? id,
    Value<int>? goalId,
    Value<String?>? goalTitle,
    Value<String>? title,
    Value<String?>? description,
    Value<int>? order,
    Value<DateTime>? scheduledAt,
    Value<DateTime>? endAt,
    Value<int>? durationMinutes,
    Value<String>? status,
    Value<bool>? isLocked,
    Value<String?>? notes,
    Value<DateTime?>? completedAt,
    Value<DateTime>? cachedAt,
  }) {
    return TasksCompanion(
      id: id ?? this.id,
      goalId: goalId ?? this.goalId,
      goalTitle: goalTitle ?? this.goalTitle,
      title: title ?? this.title,
      description: description ?? this.description,
      order: order ?? this.order,
      scheduledAt: scheduledAt ?? this.scheduledAt,
      endAt: endAt ?? this.endAt,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      status: status ?? this.status,
      isLocked: isLocked ?? this.isLocked,
      notes: notes ?? this.notes,
      completedAt: completedAt ?? this.completedAt,
      cachedAt: cachedAt ?? this.cachedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (goalId.present) {
      map['goal_id'] = Variable<int>(goalId.value);
    }
    if (goalTitle.present) {
      map['goal_title'] = Variable<String>(goalTitle.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (order.present) {
      map['order'] = Variable<int>(order.value);
    }
    if (scheduledAt.present) {
      map['scheduled_at'] = Variable<int>(
        $TasksTable.$converterscheduledAt.toSql(scheduledAt.value),
      );
    }
    if (endAt.present) {
      map['end_at'] = Variable<int>(
        $TasksTable.$converterendAt.toSql(endAt.value),
      );
    }
    if (durationMinutes.present) {
      map['duration_minutes'] = Variable<int>(durationMinutes.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (isLocked.present) {
      map['is_locked'] = Variable<bool>(isLocked.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (completedAt.present) {
      map['completed_at'] = Variable<int>(
        $TasksTable.$convertercompletedAtn.toSql(completedAt.value),
      );
    }
    if (cachedAt.present) {
      map['cached_at'] = Variable<int>(
        $TasksTable.$convertercachedAt.toSql(cachedAt.value),
      );
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TasksCompanion(')
          ..write('id: $id, ')
          ..write('goalId: $goalId, ')
          ..write('goalTitle: $goalTitle, ')
          ..write('title: $title, ')
          ..write('description: $description, ')
          ..write('order: $order, ')
          ..write('scheduledAt: $scheduledAt, ')
          ..write('endAt: $endAt, ')
          ..write('durationMinutes: $durationMinutes, ')
          ..write('status: $status, ')
          ..write('isLocked: $isLocked, ')
          ..write('notes: $notes, ')
          ..write('completedAt: $completedAt, ')
          ..write('cachedAt: $cachedAt')
          ..write(')'))
        .toString();
  }
}

class $GoalsTable extends Goals with TableInfo<$GoalsTable, GoalDbModel> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $GoalsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
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
  static const VerificationMeta _descriptionMeta = const VerificationMeta(
    'description',
  );
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  late final GeneratedColumnWithTypeConverter<DateTime, int> deadline =
      GeneratedColumn<int>(
        'deadline',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: true,
      ).withConverter<DateTime>($GoalsTable.$converterdeadline);
  static const VerificationMeta _sessionDurationMinutesMeta =
      const VerificationMeta('sessionDurationMinutes');
  @override
  late final GeneratedColumn<int> sessionDurationMinutes = GeneratedColumn<int>(
    'session_duration_minutes',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
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
  static const VerificationMeta _totalSessionsMeta = const VerificationMeta(
    'totalSessions',
  );
  @override
  late final GeneratedColumn<int> totalSessions = GeneratedColumn<int>(
    'total_sessions',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _totalHoursMeta = const VerificationMeta(
    'totalHours',
  );
  @override
  late final GeneratedColumn<double> totalHours = GeneratedColumn<double>(
    'total_hours',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  @override
  late final GeneratedColumnWithTypeConverter<DateTime?, int> completedAt =
      GeneratedColumn<int>(
        'completed_at',
        aliasedName,
        true,
        type: DriftSqlType.int,
        requiredDuringInsert: false,
      ).withConverter<DateTime?>($GoalsTable.$convertercompletedAtn);
  @override
  late final GeneratedColumnWithTypeConverter<DateTime, int> createdAt =
      GeneratedColumn<int>(
        'created_at',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: true,
      ).withConverter<DateTime>($GoalsTable.$convertercreatedAt);
  @override
  late final GeneratedColumnWithTypeConverter<DateTime, int> updatedAt =
      GeneratedColumn<int>(
        'updated_at',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: true,
      ).withConverter<DateTime>($GoalsTable.$converterupdatedAt);
  static const VerificationMeta _tasksCountMeta = const VerificationMeta(
    'tasksCount',
  );
  @override
  late final GeneratedColumn<int> tasksCount = GeneratedColumn<int>(
    'tasks_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _completedTasksCountMeta =
      const VerificationMeta('completedTasksCount');
  @override
  late final GeneratedColumn<int> completedTasksCount = GeneratedColumn<int>(
    'completed_tasks_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  late final GeneratedColumnWithTypeConverter<DateTime, int> cachedAt =
      GeneratedColumn<int>(
        'cached_at',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: true,
      ).withConverter<DateTime>($GoalsTable.$convertercachedAt);
  @override
  List<GeneratedColumn> get $columns => [
    id,
    title,
    description,
    deadline,
    sessionDurationMinutes,
    status,
    totalSessions,
    totalHours,
    completedAt,
    createdAt,
    updatedAt,
    tasksCount,
    completedTasksCount,
    cachedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'goals';
  @override
  VerificationContext validateIntegrity(
    Insertable<GoalDbModel> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
        _descriptionMeta,
        description.isAcceptableOrUnknown(
          data['description']!,
          _descriptionMeta,
        ),
      );
    }
    if (data.containsKey('session_duration_minutes')) {
      context.handle(
        _sessionDurationMinutesMeta,
        sessionDurationMinutes.isAcceptableOrUnknown(
          data['session_duration_minutes']!,
          _sessionDurationMinutesMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_sessionDurationMinutesMeta);
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    if (data.containsKey('total_sessions')) {
      context.handle(
        _totalSessionsMeta,
        totalSessions.isAcceptableOrUnknown(
          data['total_sessions']!,
          _totalSessionsMeta,
        ),
      );
    }
    if (data.containsKey('total_hours')) {
      context.handle(
        _totalHoursMeta,
        totalHours.isAcceptableOrUnknown(data['total_hours']!, _totalHoursMeta),
      );
    }
    if (data.containsKey('tasks_count')) {
      context.handle(
        _tasksCountMeta,
        tasksCount.isAcceptableOrUnknown(data['tasks_count']!, _tasksCountMeta),
      );
    }
    if (data.containsKey('completed_tasks_count')) {
      context.handle(
        _completedTasksCountMeta,
        completedTasksCount.isAcceptableOrUnknown(
          data['completed_tasks_count']!,
          _completedTasksCountMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  GoalDbModel map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return GoalDbModel(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      ),
      deadline: $GoalsTable.$converterdeadline.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}deadline'],
        )!,
      ),
      sessionDurationMinutes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}session_duration_minutes'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      totalSessions: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}total_sessions'],
      ),
      totalHours: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}total_hours'],
      ),
      completedAt: $GoalsTable.$convertercompletedAtn.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}completed_at'],
        ),
      ),
      createdAt: $GoalsTable.$convertercreatedAt.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}created_at'],
        )!,
      ),
      updatedAt: $GoalsTable.$converterupdatedAt.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}updated_at'],
        )!,
      ),
      tasksCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}tasks_count'],
      )!,
      completedTasksCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}completed_tasks_count'],
      )!,
      cachedAt: $GoalsTable.$convertercachedAt.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}cached_at'],
        )!,
      ),
    );
  }

  @override
  $GoalsTable createAlias(String alias) {
    return $GoalsTable(attachedDatabase, alias);
  }

  static TypeConverter<DateTime, int> $converterdeadline =
      const DateTimeConverter();
  static TypeConverter<DateTime, int> $convertercompletedAt =
      const DateTimeConverter();
  static TypeConverter<DateTime?, int?> $convertercompletedAtn =
      NullAwareTypeConverter.wrap($convertercompletedAt);
  static TypeConverter<DateTime, int> $convertercreatedAt =
      const DateTimeConverter();
  static TypeConverter<DateTime, int> $converterupdatedAt =
      const DateTimeConverter();
  static TypeConverter<DateTime, int> $convertercachedAt =
      const DateTimeConverter();
}

class GoalDbModel extends DataClass implements Insertable<GoalDbModel> {
  /// Unique identifier (primary key).
  final int id;

  /// Goal title.
  final String title;

  /// Optional description.
  final String? description;

  /// Deadline (Unix timestamp).
  final DateTime deadline;

  /// Session duration in minutes.
  final int sessionDurationMinutes;

  /// Status: draft, active, completed.
  final String status;

  /// Total number of sessions.
  final int? totalSessions;

  /// Total hours planned.
  final double? totalHours;

  /// When the goal was completed (Unix timestamp, nullable).
  final DateTime? completedAt;

  /// Created at (Unix timestamp).
  final DateTime createdAt;

  /// Updated at (Unix timestamp).
  final DateTime updatedAt;

  /// Cached task count (denormalized for performance).
  final int tasksCount;

  /// Cached completed task count (denormalized for performance).
  final int completedTasksCount;

  /// When this record was cached (for cache invalidation).
  final DateTime cachedAt;
  const GoalDbModel({
    required this.id,
    required this.title,
    this.description,
    required this.deadline,
    required this.sessionDurationMinutes,
    required this.status,
    this.totalSessions,
    this.totalHours,
    this.completedAt,
    required this.createdAt,
    required this.updatedAt,
    required this.tasksCount,
    required this.completedTasksCount,
    required this.cachedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['title'] = Variable<String>(title);
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    {
      map['deadline'] = Variable<int>(
        $GoalsTable.$converterdeadline.toSql(deadline),
      );
    }
    map['session_duration_minutes'] = Variable<int>(sessionDurationMinutes);
    map['status'] = Variable<String>(status);
    if (!nullToAbsent || totalSessions != null) {
      map['total_sessions'] = Variable<int>(totalSessions);
    }
    if (!nullToAbsent || totalHours != null) {
      map['total_hours'] = Variable<double>(totalHours);
    }
    if (!nullToAbsent || completedAt != null) {
      map['completed_at'] = Variable<int>(
        $GoalsTable.$convertercompletedAtn.toSql(completedAt),
      );
    }
    {
      map['created_at'] = Variable<int>(
        $GoalsTable.$convertercreatedAt.toSql(createdAt),
      );
    }
    {
      map['updated_at'] = Variable<int>(
        $GoalsTable.$converterupdatedAt.toSql(updatedAt),
      );
    }
    map['tasks_count'] = Variable<int>(tasksCount);
    map['completed_tasks_count'] = Variable<int>(completedTasksCount);
    {
      map['cached_at'] = Variable<int>(
        $GoalsTable.$convertercachedAt.toSql(cachedAt),
      );
    }
    return map;
  }

  GoalsCompanion toCompanion(bool nullToAbsent) {
    return GoalsCompanion(
      id: Value(id),
      title: Value(title),
      description: description == null && nullToAbsent
          ? const Value.absent()
          : Value(description),
      deadline: Value(deadline),
      sessionDurationMinutes: Value(sessionDurationMinutes),
      status: Value(status),
      totalSessions: totalSessions == null && nullToAbsent
          ? const Value.absent()
          : Value(totalSessions),
      totalHours: totalHours == null && nullToAbsent
          ? const Value.absent()
          : Value(totalHours),
      completedAt: completedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(completedAt),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      tasksCount: Value(tasksCount),
      completedTasksCount: Value(completedTasksCount),
      cachedAt: Value(cachedAt),
    );
  }

  factory GoalDbModel.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return GoalDbModel(
      id: serializer.fromJson<int>(json['id']),
      title: serializer.fromJson<String>(json['title']),
      description: serializer.fromJson<String?>(json['description']),
      deadline: serializer.fromJson<DateTime>(json['deadline']),
      sessionDurationMinutes: serializer.fromJson<int>(
        json['sessionDurationMinutes'],
      ),
      status: serializer.fromJson<String>(json['status']),
      totalSessions: serializer.fromJson<int?>(json['totalSessions']),
      totalHours: serializer.fromJson<double?>(json['totalHours']),
      completedAt: serializer.fromJson<DateTime?>(json['completedAt']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      tasksCount: serializer.fromJson<int>(json['tasksCount']),
      completedTasksCount: serializer.fromJson<int>(
        json['completedTasksCount'],
      ),
      cachedAt: serializer.fromJson<DateTime>(json['cachedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'title': serializer.toJson<String>(title),
      'description': serializer.toJson<String?>(description),
      'deadline': serializer.toJson<DateTime>(deadline),
      'sessionDurationMinutes': serializer.toJson<int>(sessionDurationMinutes),
      'status': serializer.toJson<String>(status),
      'totalSessions': serializer.toJson<int?>(totalSessions),
      'totalHours': serializer.toJson<double?>(totalHours),
      'completedAt': serializer.toJson<DateTime?>(completedAt),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'tasksCount': serializer.toJson<int>(tasksCount),
      'completedTasksCount': serializer.toJson<int>(completedTasksCount),
      'cachedAt': serializer.toJson<DateTime>(cachedAt),
    };
  }

  GoalDbModel copyWith({
    int? id,
    String? title,
    Value<String?> description = const Value.absent(),
    DateTime? deadline,
    int? sessionDurationMinutes,
    String? status,
    Value<int?> totalSessions = const Value.absent(),
    Value<double?> totalHours = const Value.absent(),
    Value<DateTime?> completedAt = const Value.absent(),
    DateTime? createdAt,
    DateTime? updatedAt,
    int? tasksCount,
    int? completedTasksCount,
    DateTime? cachedAt,
  }) => GoalDbModel(
    id: id ?? this.id,
    title: title ?? this.title,
    description: description.present ? description.value : this.description,
    deadline: deadline ?? this.deadline,
    sessionDurationMinutes:
        sessionDurationMinutes ?? this.sessionDurationMinutes,
    status: status ?? this.status,
    totalSessions: totalSessions.present
        ? totalSessions.value
        : this.totalSessions,
    totalHours: totalHours.present ? totalHours.value : this.totalHours,
    completedAt: completedAt.present ? completedAt.value : this.completedAt,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    tasksCount: tasksCount ?? this.tasksCount,
    completedTasksCount: completedTasksCount ?? this.completedTasksCount,
    cachedAt: cachedAt ?? this.cachedAt,
  );
  GoalDbModel copyWithCompanion(GoalsCompanion data) {
    return GoalDbModel(
      id: data.id.present ? data.id.value : this.id,
      title: data.title.present ? data.title.value : this.title,
      description: data.description.present
          ? data.description.value
          : this.description,
      deadline: data.deadline.present ? data.deadline.value : this.deadline,
      sessionDurationMinutes: data.sessionDurationMinutes.present
          ? data.sessionDurationMinutes.value
          : this.sessionDurationMinutes,
      status: data.status.present ? data.status.value : this.status,
      totalSessions: data.totalSessions.present
          ? data.totalSessions.value
          : this.totalSessions,
      totalHours: data.totalHours.present
          ? data.totalHours.value
          : this.totalHours,
      completedAt: data.completedAt.present
          ? data.completedAt.value
          : this.completedAt,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      tasksCount: data.tasksCount.present
          ? data.tasksCount.value
          : this.tasksCount,
      completedTasksCount: data.completedTasksCount.present
          ? data.completedTasksCount.value
          : this.completedTasksCount,
      cachedAt: data.cachedAt.present ? data.cachedAt.value : this.cachedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('GoalDbModel(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('description: $description, ')
          ..write('deadline: $deadline, ')
          ..write('sessionDurationMinutes: $sessionDurationMinutes, ')
          ..write('status: $status, ')
          ..write('totalSessions: $totalSessions, ')
          ..write('totalHours: $totalHours, ')
          ..write('completedAt: $completedAt, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('tasksCount: $tasksCount, ')
          ..write('completedTasksCount: $completedTasksCount, ')
          ..write('cachedAt: $cachedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    title,
    description,
    deadline,
    sessionDurationMinutes,
    status,
    totalSessions,
    totalHours,
    completedAt,
    createdAt,
    updatedAt,
    tasksCount,
    completedTasksCount,
    cachedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is GoalDbModel &&
          other.id == this.id &&
          other.title == this.title &&
          other.description == this.description &&
          other.deadline == this.deadline &&
          other.sessionDurationMinutes == this.sessionDurationMinutes &&
          other.status == this.status &&
          other.totalSessions == this.totalSessions &&
          other.totalHours == this.totalHours &&
          other.completedAt == this.completedAt &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.tasksCount == this.tasksCount &&
          other.completedTasksCount == this.completedTasksCount &&
          other.cachedAt == this.cachedAt);
}

class GoalsCompanion extends UpdateCompanion<GoalDbModel> {
  final Value<int> id;
  final Value<String> title;
  final Value<String?> description;
  final Value<DateTime> deadline;
  final Value<int> sessionDurationMinutes;
  final Value<String> status;
  final Value<int?> totalSessions;
  final Value<double?> totalHours;
  final Value<DateTime?> completedAt;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> tasksCount;
  final Value<int> completedTasksCount;
  final Value<DateTime> cachedAt;
  const GoalsCompanion({
    this.id = const Value.absent(),
    this.title = const Value.absent(),
    this.description = const Value.absent(),
    this.deadline = const Value.absent(),
    this.sessionDurationMinutes = const Value.absent(),
    this.status = const Value.absent(),
    this.totalSessions = const Value.absent(),
    this.totalHours = const Value.absent(),
    this.completedAt = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.tasksCount = const Value.absent(),
    this.completedTasksCount = const Value.absent(),
    this.cachedAt = const Value.absent(),
  });
  GoalsCompanion.insert({
    this.id = const Value.absent(),
    required String title,
    this.description = const Value.absent(),
    required DateTime deadline,
    required int sessionDurationMinutes,
    required String status,
    this.totalSessions = const Value.absent(),
    this.totalHours = const Value.absent(),
    this.completedAt = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.tasksCount = const Value.absent(),
    this.completedTasksCount = const Value.absent(),
    required DateTime cachedAt,
  }) : title = Value(title),
       deadline = Value(deadline),
       sessionDurationMinutes = Value(sessionDurationMinutes),
       status = Value(status),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt),
       cachedAt = Value(cachedAt);
  static Insertable<GoalDbModel> custom({
    Expression<int>? id,
    Expression<String>? title,
    Expression<String>? description,
    Expression<int>? deadline,
    Expression<int>? sessionDurationMinutes,
    Expression<String>? status,
    Expression<int>? totalSessions,
    Expression<double>? totalHours,
    Expression<int>? completedAt,
    Expression<int>? createdAt,
    Expression<int>? updatedAt,
    Expression<int>? tasksCount,
    Expression<int>? completedTasksCount,
    Expression<int>? cachedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (title != null) 'title': title,
      if (description != null) 'description': description,
      if (deadline != null) 'deadline': deadline,
      if (sessionDurationMinutes != null)
        'session_duration_minutes': sessionDurationMinutes,
      if (status != null) 'status': status,
      if (totalSessions != null) 'total_sessions': totalSessions,
      if (totalHours != null) 'total_hours': totalHours,
      if (completedAt != null) 'completed_at': completedAt,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (tasksCount != null) 'tasks_count': tasksCount,
      if (completedTasksCount != null)
        'completed_tasks_count': completedTasksCount,
      if (cachedAt != null) 'cached_at': cachedAt,
    });
  }

  GoalsCompanion copyWith({
    Value<int>? id,
    Value<String>? title,
    Value<String?>? description,
    Value<DateTime>? deadline,
    Value<int>? sessionDurationMinutes,
    Value<String>? status,
    Value<int?>? totalSessions,
    Value<double?>? totalHours,
    Value<DateTime?>? completedAt,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<int>? tasksCount,
    Value<int>? completedTasksCount,
    Value<DateTime>? cachedAt,
  }) {
    return GoalsCompanion(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      deadline: deadline ?? this.deadline,
      sessionDurationMinutes:
          sessionDurationMinutes ?? this.sessionDurationMinutes,
      status: status ?? this.status,
      totalSessions: totalSessions ?? this.totalSessions,
      totalHours: totalHours ?? this.totalHours,
      completedAt: completedAt ?? this.completedAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      tasksCount: tasksCount ?? this.tasksCount,
      completedTasksCount: completedTasksCount ?? this.completedTasksCount,
      cachedAt: cachedAt ?? this.cachedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (deadline.present) {
      map['deadline'] = Variable<int>(
        $GoalsTable.$converterdeadline.toSql(deadline.value),
      );
    }
    if (sessionDurationMinutes.present) {
      map['session_duration_minutes'] = Variable<int>(
        sessionDurationMinutes.value,
      );
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (totalSessions.present) {
      map['total_sessions'] = Variable<int>(totalSessions.value);
    }
    if (totalHours.present) {
      map['total_hours'] = Variable<double>(totalHours.value);
    }
    if (completedAt.present) {
      map['completed_at'] = Variable<int>(
        $GoalsTable.$convertercompletedAtn.toSql(completedAt.value),
      );
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(
        $GoalsTable.$convertercreatedAt.toSql(createdAt.value),
      );
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(
        $GoalsTable.$converterupdatedAt.toSql(updatedAt.value),
      );
    }
    if (tasksCount.present) {
      map['tasks_count'] = Variable<int>(tasksCount.value);
    }
    if (completedTasksCount.present) {
      map['completed_tasks_count'] = Variable<int>(completedTasksCount.value);
    }
    if (cachedAt.present) {
      map['cached_at'] = Variable<int>(
        $GoalsTable.$convertercachedAt.toSql(cachedAt.value),
      );
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('GoalsCompanion(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('description: $description, ')
          ..write('deadline: $deadline, ')
          ..write('sessionDurationMinutes: $sessionDurationMinutes, ')
          ..write('status: $status, ')
          ..write('totalSessions: $totalSessions, ')
          ..write('totalHours: $totalHours, ')
          ..write('completedAt: $completedAt, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('tasksCount: $tasksCount, ')
          ..write('completedTasksCount: $completedTasksCount, ')
          ..write('cachedAt: $cachedAt')
          ..write(')'))
        .toString();
  }
}

class $AvailabilityRulesTable extends AvailabilityRules
    with TableInfo<$AvailabilityRulesTable, AvailabilityRuleDbModel> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AvailabilityRulesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _localIdMeta = const VerificationMeta(
    'localId',
  );
  @override
  late final GeneratedColumn<int> localId = GeneratedColumn<int>(
    'local_id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _goalIdMeta = const VerificationMeta('goalId');
  @override
  late final GeneratedColumn<int> goalId = GeneratedColumn<int>(
    'goal_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dayMeta = const VerificationMeta('day');
  @override
  late final GeneratedColumn<String> day = GeneratedColumn<String>(
    'day',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _startMeta = const VerificationMeta('start');
  @override
  late final GeneratedColumn<String> start = GeneratedColumn<String>(
    'start',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _endMeta = const VerificationMeta('end');
  @override
  late final GeneratedColumn<String> end = GeneratedColumn<String>(
    'end',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [localId, goalId, day, start, end];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'availability_rules';
  @override
  VerificationContext validateIntegrity(
    Insertable<AvailabilityRuleDbModel> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('local_id')) {
      context.handle(
        _localIdMeta,
        localId.isAcceptableOrUnknown(data['local_id']!, _localIdMeta),
      );
    }
    if (data.containsKey('goal_id')) {
      context.handle(
        _goalIdMeta,
        goalId.isAcceptableOrUnknown(data['goal_id']!, _goalIdMeta),
      );
    } else if (isInserting) {
      context.missing(_goalIdMeta);
    }
    if (data.containsKey('day')) {
      context.handle(
        _dayMeta,
        day.isAcceptableOrUnknown(data['day']!, _dayMeta),
      );
    } else if (isInserting) {
      context.missing(_dayMeta);
    }
    if (data.containsKey('start')) {
      context.handle(
        _startMeta,
        start.isAcceptableOrUnknown(data['start']!, _startMeta),
      );
    } else if (isInserting) {
      context.missing(_startMeta);
    }
    if (data.containsKey('end')) {
      context.handle(
        _endMeta,
        end.isAcceptableOrUnknown(data['end']!, _endMeta),
      );
    } else if (isInserting) {
      context.missing(_endMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {localId};
  @override
  AvailabilityRuleDbModel map(
    Map<String, dynamic> data, {
    String? tablePrefix,
  }) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AvailabilityRuleDbModel(
      localId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}local_id'],
      )!,
      goalId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}goal_id'],
      )!,
      day: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}day'],
      )!,
      start: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}start'],
      )!,
      end: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}end'],
      )!,
    );
  }

  @override
  $AvailabilityRulesTable createAlias(String alias) {
    return $AvailabilityRulesTable(attachedDatabase, alias);
  }
}

class AvailabilityRuleDbModel extends DataClass
    implements Insertable<AvailabilityRuleDbModel> {
  /// Auto-increment local ID (not the same as server ID).
  final int localId;

  /// Foreign key to the goal this rule belongs to.
  final int goalId;

  /// Day of week (e.g., "monday", "tuesday").
  final String day;

  /// Start time in HH:mm format.
  final String start;

  /// End time in HH:mm format.
  final String end;
  const AvailabilityRuleDbModel({
    required this.localId,
    required this.goalId,
    required this.day,
    required this.start,
    required this.end,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['local_id'] = Variable<int>(localId);
    map['goal_id'] = Variable<int>(goalId);
    map['day'] = Variable<String>(day);
    map['start'] = Variable<String>(start);
    map['end'] = Variable<String>(end);
    return map;
  }

  AvailabilityRulesCompanion toCompanion(bool nullToAbsent) {
    return AvailabilityRulesCompanion(
      localId: Value(localId),
      goalId: Value(goalId),
      day: Value(day),
      start: Value(start),
      end: Value(end),
    );
  }

  factory AvailabilityRuleDbModel.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AvailabilityRuleDbModel(
      localId: serializer.fromJson<int>(json['localId']),
      goalId: serializer.fromJson<int>(json['goalId']),
      day: serializer.fromJson<String>(json['day']),
      start: serializer.fromJson<String>(json['start']),
      end: serializer.fromJson<String>(json['end']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'localId': serializer.toJson<int>(localId),
      'goalId': serializer.toJson<int>(goalId),
      'day': serializer.toJson<String>(day),
      'start': serializer.toJson<String>(start),
      'end': serializer.toJson<String>(end),
    };
  }

  AvailabilityRuleDbModel copyWith({
    int? localId,
    int? goalId,
    String? day,
    String? start,
    String? end,
  }) => AvailabilityRuleDbModel(
    localId: localId ?? this.localId,
    goalId: goalId ?? this.goalId,
    day: day ?? this.day,
    start: start ?? this.start,
    end: end ?? this.end,
  );
  AvailabilityRuleDbModel copyWithCompanion(AvailabilityRulesCompanion data) {
    return AvailabilityRuleDbModel(
      localId: data.localId.present ? data.localId.value : this.localId,
      goalId: data.goalId.present ? data.goalId.value : this.goalId,
      day: data.day.present ? data.day.value : this.day,
      start: data.start.present ? data.start.value : this.start,
      end: data.end.present ? data.end.value : this.end,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AvailabilityRuleDbModel(')
          ..write('localId: $localId, ')
          ..write('goalId: $goalId, ')
          ..write('day: $day, ')
          ..write('start: $start, ')
          ..write('end: $end')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(localId, goalId, day, start, end);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AvailabilityRuleDbModel &&
          other.localId == this.localId &&
          other.goalId == this.goalId &&
          other.day == this.day &&
          other.start == this.start &&
          other.end == this.end);
}

class AvailabilityRulesCompanion
    extends UpdateCompanion<AvailabilityRuleDbModel> {
  final Value<int> localId;
  final Value<int> goalId;
  final Value<String> day;
  final Value<String> start;
  final Value<String> end;
  const AvailabilityRulesCompanion({
    this.localId = const Value.absent(),
    this.goalId = const Value.absent(),
    this.day = const Value.absent(),
    this.start = const Value.absent(),
    this.end = const Value.absent(),
  });
  AvailabilityRulesCompanion.insert({
    this.localId = const Value.absent(),
    required int goalId,
    required String day,
    required String start,
    required String end,
  }) : goalId = Value(goalId),
       day = Value(day),
       start = Value(start),
       end = Value(end);
  static Insertable<AvailabilityRuleDbModel> custom({
    Expression<int>? localId,
    Expression<int>? goalId,
    Expression<String>? day,
    Expression<String>? start,
    Expression<String>? end,
  }) {
    return RawValuesInsertable({
      if (localId != null) 'local_id': localId,
      if (goalId != null) 'goal_id': goalId,
      if (day != null) 'day': day,
      if (start != null) 'start': start,
      if (end != null) 'end': end,
    });
  }

  AvailabilityRulesCompanion copyWith({
    Value<int>? localId,
    Value<int>? goalId,
    Value<String>? day,
    Value<String>? start,
    Value<String>? end,
  }) {
    return AvailabilityRulesCompanion(
      localId: localId ?? this.localId,
      goalId: goalId ?? this.goalId,
      day: day ?? this.day,
      start: start ?? this.start,
      end: end ?? this.end,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (localId.present) {
      map['local_id'] = Variable<int>(localId.value);
    }
    if (goalId.present) {
      map['goal_id'] = Variable<int>(goalId.value);
    }
    if (day.present) {
      map['day'] = Variable<String>(day.value);
    }
    if (start.present) {
      map['start'] = Variable<String>(start.value);
    }
    if (end.present) {
      map['end'] = Variable<String>(end.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AvailabilityRulesCompanion(')
          ..write('localId: $localId, ')
          ..write('goalId: $goalId, ')
          ..write('day: $day, ')
          ..write('start: $start, ')
          ..write('end: $end')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $TasksTable tasks = $TasksTable(this);
  late final $GoalsTable goals = $GoalsTable(this);
  late final $AvailabilityRulesTable availabilityRules =
      $AvailabilityRulesTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    tasks,
    goals,
    availabilityRules,
  ];
}

typedef $$TasksTableCreateCompanionBuilder =
    TasksCompanion Function({
      Value<int> id,
      required int goalId,
      Value<String?> goalTitle,
      required String title,
      Value<String?> description,
      Value<int> order,
      required DateTime scheduledAt,
      required DateTime endAt,
      required int durationMinutes,
      required String status,
      Value<bool> isLocked,
      Value<String?> notes,
      Value<DateTime?> completedAt,
      required DateTime cachedAt,
    });
typedef $$TasksTableUpdateCompanionBuilder =
    TasksCompanion Function({
      Value<int> id,
      Value<int> goalId,
      Value<String?> goalTitle,
      Value<String> title,
      Value<String?> description,
      Value<int> order,
      Value<DateTime> scheduledAt,
      Value<DateTime> endAt,
      Value<int> durationMinutes,
      Value<String> status,
      Value<bool> isLocked,
      Value<String?> notes,
      Value<DateTime?> completedAt,
      Value<DateTime> cachedAt,
    });

class $$TasksTableFilterComposer extends Composer<_$AppDatabase, $TasksTable> {
  $$TasksTableFilterComposer({
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

  ColumnFilters<int> get goalId => $composableBuilder(
    column: $table.goalId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get goalTitle => $composableBuilder(
    column: $table.goalTitle,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get order => $composableBuilder(
    column: $table.order,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<DateTime, DateTime, int> get scheduledAt =>
      $composableBuilder(
        column: $table.scheduledAt,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnWithTypeConverterFilters<DateTime, DateTime, int> get endAt =>
      $composableBuilder(
        column: $table.endAt,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<int> get durationMinutes => $composableBuilder(
    column: $table.durationMinutes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isLocked => $composableBuilder(
    column: $table.isLocked,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<DateTime?, DateTime, int> get completedAt =>
      $composableBuilder(
        column: $table.completedAt,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnWithTypeConverterFilters<DateTime, DateTime, int> get cachedAt =>
      $composableBuilder(
        column: $table.cachedAt,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );
}

class $$TasksTableOrderingComposer
    extends Composer<_$AppDatabase, $TasksTable> {
  $$TasksTableOrderingComposer({
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

  ColumnOrderings<int> get goalId => $composableBuilder(
    column: $table.goalId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get goalTitle => $composableBuilder(
    column: $table.goalTitle,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get order => $composableBuilder(
    column: $table.order,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get scheduledAt => $composableBuilder(
    column: $table.scheduledAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get endAt => $composableBuilder(
    column: $table.endAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get durationMinutes => $composableBuilder(
    column: $table.durationMinutes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isLocked => $composableBuilder(
    column: $table.isLocked,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get cachedAt => $composableBuilder(
    column: $table.cachedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$TasksTableAnnotationComposer
    extends Composer<_$AppDatabase, $TasksTable> {
  $$TasksTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get goalId =>
      $composableBuilder(column: $table.goalId, builder: (column) => column);

  GeneratedColumn<String> get goalTitle =>
      $composableBuilder(column: $table.goalTitle, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumn<int> get order =>
      $composableBuilder(column: $table.order, builder: (column) => column);

  GeneratedColumnWithTypeConverter<DateTime, int> get scheduledAt =>
      $composableBuilder(
        column: $table.scheduledAt,
        builder: (column) => column,
      );

  GeneratedColumnWithTypeConverter<DateTime, int> get endAt =>
      $composableBuilder(column: $table.endAt, builder: (column) => column);

  GeneratedColumn<int> get durationMinutes => $composableBuilder(
    column: $table.durationMinutes,
    builder: (column) => column,
  );

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<bool> get isLocked =>
      $composableBuilder(column: $table.isLocked, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumnWithTypeConverter<DateTime?, int> get completedAt =>
      $composableBuilder(
        column: $table.completedAt,
        builder: (column) => column,
      );

  GeneratedColumnWithTypeConverter<DateTime, int> get cachedAt =>
      $composableBuilder(column: $table.cachedAt, builder: (column) => column);
}

class $$TasksTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TasksTable,
          TaskDbModel,
          $$TasksTableFilterComposer,
          $$TasksTableOrderingComposer,
          $$TasksTableAnnotationComposer,
          $$TasksTableCreateCompanionBuilder,
          $$TasksTableUpdateCompanionBuilder,
          (
            TaskDbModel,
            BaseReferences<_$AppDatabase, $TasksTable, TaskDbModel>,
          ),
          TaskDbModel,
          PrefetchHooks Function()
        > {
  $$TasksTableTableManager(_$AppDatabase db, $TasksTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TasksTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TasksTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TasksTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> goalId = const Value.absent(),
                Value<String?> goalTitle = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String?> description = const Value.absent(),
                Value<int> order = const Value.absent(),
                Value<DateTime> scheduledAt = const Value.absent(),
                Value<DateTime> endAt = const Value.absent(),
                Value<int> durationMinutes = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<bool> isLocked = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<DateTime?> completedAt = const Value.absent(),
                Value<DateTime> cachedAt = const Value.absent(),
              }) => TasksCompanion(
                id: id,
                goalId: goalId,
                goalTitle: goalTitle,
                title: title,
                description: description,
                order: order,
                scheduledAt: scheduledAt,
                endAt: endAt,
                durationMinutes: durationMinutes,
                status: status,
                isLocked: isLocked,
                notes: notes,
                completedAt: completedAt,
                cachedAt: cachedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int goalId,
                Value<String?> goalTitle = const Value.absent(),
                required String title,
                Value<String?> description = const Value.absent(),
                Value<int> order = const Value.absent(),
                required DateTime scheduledAt,
                required DateTime endAt,
                required int durationMinutes,
                required String status,
                Value<bool> isLocked = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<DateTime?> completedAt = const Value.absent(),
                required DateTime cachedAt,
              }) => TasksCompanion.insert(
                id: id,
                goalId: goalId,
                goalTitle: goalTitle,
                title: title,
                description: description,
                order: order,
                scheduledAt: scheduledAt,
                endAt: endAt,
                durationMinutes: durationMinutes,
                status: status,
                isLocked: isLocked,
                notes: notes,
                completedAt: completedAt,
                cachedAt: cachedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$TasksTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TasksTable,
      TaskDbModel,
      $$TasksTableFilterComposer,
      $$TasksTableOrderingComposer,
      $$TasksTableAnnotationComposer,
      $$TasksTableCreateCompanionBuilder,
      $$TasksTableUpdateCompanionBuilder,
      (TaskDbModel, BaseReferences<_$AppDatabase, $TasksTable, TaskDbModel>),
      TaskDbModel,
      PrefetchHooks Function()
    >;
typedef $$GoalsTableCreateCompanionBuilder =
    GoalsCompanion Function({
      Value<int> id,
      required String title,
      Value<String?> description,
      required DateTime deadline,
      required int sessionDurationMinutes,
      required String status,
      Value<int?> totalSessions,
      Value<double?> totalHours,
      Value<DateTime?> completedAt,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<int> tasksCount,
      Value<int> completedTasksCount,
      required DateTime cachedAt,
    });
typedef $$GoalsTableUpdateCompanionBuilder =
    GoalsCompanion Function({
      Value<int> id,
      Value<String> title,
      Value<String?> description,
      Value<DateTime> deadline,
      Value<int> sessionDurationMinutes,
      Value<String> status,
      Value<int?> totalSessions,
      Value<double?> totalHours,
      Value<DateTime?> completedAt,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<int> tasksCount,
      Value<int> completedTasksCount,
      Value<DateTime> cachedAt,
    });

class $$GoalsTableFilterComposer extends Composer<_$AppDatabase, $GoalsTable> {
  $$GoalsTableFilterComposer({
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

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<DateTime, DateTime, int> get deadline =>
      $composableBuilder(
        column: $table.deadline,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<int> get sessionDurationMinutes => $composableBuilder(
    column: $table.sessionDurationMinutes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get totalSessions => $composableBuilder(
    column: $table.totalSessions,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get totalHours => $composableBuilder(
    column: $table.totalHours,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<DateTime?, DateTime, int> get completedAt =>
      $composableBuilder(
        column: $table.completedAt,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnWithTypeConverterFilters<DateTime, DateTime, int> get createdAt =>
      $composableBuilder(
        column: $table.createdAt,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnWithTypeConverterFilters<DateTime, DateTime, int> get updatedAt =>
      $composableBuilder(
        column: $table.updatedAt,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<int> get tasksCount => $composableBuilder(
    column: $table.tasksCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get completedTasksCount => $composableBuilder(
    column: $table.completedTasksCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<DateTime, DateTime, int> get cachedAt =>
      $composableBuilder(
        column: $table.cachedAt,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );
}

class $$GoalsTableOrderingComposer
    extends Composer<_$AppDatabase, $GoalsTable> {
  $$GoalsTableOrderingComposer({
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

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get deadline => $composableBuilder(
    column: $table.deadline,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sessionDurationMinutes => $composableBuilder(
    column: $table.sessionDurationMinutes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get totalSessions => $composableBuilder(
    column: $table.totalSessions,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get totalHours => $composableBuilder(
    column: $table.totalHours,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get tasksCount => $composableBuilder(
    column: $table.tasksCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get completedTasksCount => $composableBuilder(
    column: $table.completedTasksCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get cachedAt => $composableBuilder(
    column: $table.cachedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$GoalsTableAnnotationComposer
    extends Composer<_$AppDatabase, $GoalsTable> {
  $$GoalsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<DateTime, int> get deadline =>
      $composableBuilder(column: $table.deadline, builder: (column) => column);

  GeneratedColumn<int> get sessionDurationMinutes => $composableBuilder(
    column: $table.sessionDurationMinutes,
    builder: (column) => column,
  );

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<int> get totalSessions => $composableBuilder(
    column: $table.totalSessions,
    builder: (column) => column,
  );

  GeneratedColumn<double> get totalHours => $composableBuilder(
    column: $table.totalHours,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<DateTime?, int> get completedAt =>
      $composableBuilder(
        column: $table.completedAt,
        builder: (column) => column,
      );

  GeneratedColumnWithTypeConverter<DateTime, int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumnWithTypeConverter<DateTime, int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<int> get tasksCount => $composableBuilder(
    column: $table.tasksCount,
    builder: (column) => column,
  );

  GeneratedColumn<int> get completedTasksCount => $composableBuilder(
    column: $table.completedTasksCount,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<DateTime, int> get cachedAt =>
      $composableBuilder(column: $table.cachedAt, builder: (column) => column);
}

class $$GoalsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $GoalsTable,
          GoalDbModel,
          $$GoalsTableFilterComposer,
          $$GoalsTableOrderingComposer,
          $$GoalsTableAnnotationComposer,
          $$GoalsTableCreateCompanionBuilder,
          $$GoalsTableUpdateCompanionBuilder,
          (
            GoalDbModel,
            BaseReferences<_$AppDatabase, $GoalsTable, GoalDbModel>,
          ),
          GoalDbModel,
          PrefetchHooks Function()
        > {
  $$GoalsTableTableManager(_$AppDatabase db, $GoalsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$GoalsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$GoalsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$GoalsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String?> description = const Value.absent(),
                Value<DateTime> deadline = const Value.absent(),
                Value<int> sessionDurationMinutes = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<int?> totalSessions = const Value.absent(),
                Value<double?> totalHours = const Value.absent(),
                Value<DateTime?> completedAt = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> tasksCount = const Value.absent(),
                Value<int> completedTasksCount = const Value.absent(),
                Value<DateTime> cachedAt = const Value.absent(),
              }) => GoalsCompanion(
                id: id,
                title: title,
                description: description,
                deadline: deadline,
                sessionDurationMinutes: sessionDurationMinutes,
                status: status,
                totalSessions: totalSessions,
                totalHours: totalHours,
                completedAt: completedAt,
                createdAt: createdAt,
                updatedAt: updatedAt,
                tasksCount: tasksCount,
                completedTasksCount: completedTasksCount,
                cachedAt: cachedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String title,
                Value<String?> description = const Value.absent(),
                required DateTime deadline,
                required int sessionDurationMinutes,
                required String status,
                Value<int?> totalSessions = const Value.absent(),
                Value<double?> totalHours = const Value.absent(),
                Value<DateTime?> completedAt = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<int> tasksCount = const Value.absent(),
                Value<int> completedTasksCount = const Value.absent(),
                required DateTime cachedAt,
              }) => GoalsCompanion.insert(
                id: id,
                title: title,
                description: description,
                deadline: deadline,
                sessionDurationMinutes: sessionDurationMinutes,
                status: status,
                totalSessions: totalSessions,
                totalHours: totalHours,
                completedAt: completedAt,
                createdAt: createdAt,
                updatedAt: updatedAt,
                tasksCount: tasksCount,
                completedTasksCount: completedTasksCount,
                cachedAt: cachedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$GoalsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $GoalsTable,
      GoalDbModel,
      $$GoalsTableFilterComposer,
      $$GoalsTableOrderingComposer,
      $$GoalsTableAnnotationComposer,
      $$GoalsTableCreateCompanionBuilder,
      $$GoalsTableUpdateCompanionBuilder,
      (GoalDbModel, BaseReferences<_$AppDatabase, $GoalsTable, GoalDbModel>),
      GoalDbModel,
      PrefetchHooks Function()
    >;
typedef $$AvailabilityRulesTableCreateCompanionBuilder =
    AvailabilityRulesCompanion Function({
      Value<int> localId,
      required int goalId,
      required String day,
      required String start,
      required String end,
    });
typedef $$AvailabilityRulesTableUpdateCompanionBuilder =
    AvailabilityRulesCompanion Function({
      Value<int> localId,
      Value<int> goalId,
      Value<String> day,
      Value<String> start,
      Value<String> end,
    });

class $$AvailabilityRulesTableFilterComposer
    extends Composer<_$AppDatabase, $AvailabilityRulesTable> {
  $$AvailabilityRulesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get localId => $composableBuilder(
    column: $table.localId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get goalId => $composableBuilder(
    column: $table.goalId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get day => $composableBuilder(
    column: $table.day,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get start => $composableBuilder(
    column: $table.start,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get end => $composableBuilder(
    column: $table.end,
    builder: (column) => ColumnFilters(column),
  );
}

class $$AvailabilityRulesTableOrderingComposer
    extends Composer<_$AppDatabase, $AvailabilityRulesTable> {
  $$AvailabilityRulesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get localId => $composableBuilder(
    column: $table.localId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get goalId => $composableBuilder(
    column: $table.goalId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get day => $composableBuilder(
    column: $table.day,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get start => $composableBuilder(
    column: $table.start,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get end => $composableBuilder(
    column: $table.end,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AvailabilityRulesTableAnnotationComposer
    extends Composer<_$AppDatabase, $AvailabilityRulesTable> {
  $$AvailabilityRulesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get localId =>
      $composableBuilder(column: $table.localId, builder: (column) => column);

  GeneratedColumn<int> get goalId =>
      $composableBuilder(column: $table.goalId, builder: (column) => column);

  GeneratedColumn<String> get day =>
      $composableBuilder(column: $table.day, builder: (column) => column);

  GeneratedColumn<String> get start =>
      $composableBuilder(column: $table.start, builder: (column) => column);

  GeneratedColumn<String> get end =>
      $composableBuilder(column: $table.end, builder: (column) => column);
}

class $$AvailabilityRulesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AvailabilityRulesTable,
          AvailabilityRuleDbModel,
          $$AvailabilityRulesTableFilterComposer,
          $$AvailabilityRulesTableOrderingComposer,
          $$AvailabilityRulesTableAnnotationComposer,
          $$AvailabilityRulesTableCreateCompanionBuilder,
          $$AvailabilityRulesTableUpdateCompanionBuilder,
          (
            AvailabilityRuleDbModel,
            BaseReferences<
              _$AppDatabase,
              $AvailabilityRulesTable,
              AvailabilityRuleDbModel
            >,
          ),
          AvailabilityRuleDbModel,
          PrefetchHooks Function()
        > {
  $$AvailabilityRulesTableTableManager(
    _$AppDatabase db,
    $AvailabilityRulesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AvailabilityRulesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AvailabilityRulesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AvailabilityRulesTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> localId = const Value.absent(),
                Value<int> goalId = const Value.absent(),
                Value<String> day = const Value.absent(),
                Value<String> start = const Value.absent(),
                Value<String> end = const Value.absent(),
              }) => AvailabilityRulesCompanion(
                localId: localId,
                goalId: goalId,
                day: day,
                start: start,
                end: end,
              ),
          createCompanionCallback:
              ({
                Value<int> localId = const Value.absent(),
                required int goalId,
                required String day,
                required String start,
                required String end,
              }) => AvailabilityRulesCompanion.insert(
                localId: localId,
                goalId: goalId,
                day: day,
                start: start,
                end: end,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$AvailabilityRulesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AvailabilityRulesTable,
      AvailabilityRuleDbModel,
      $$AvailabilityRulesTableFilterComposer,
      $$AvailabilityRulesTableOrderingComposer,
      $$AvailabilityRulesTableAnnotationComposer,
      $$AvailabilityRulesTableCreateCompanionBuilder,
      $$AvailabilityRulesTableUpdateCompanionBuilder,
      (
        AvailabilityRuleDbModel,
        BaseReferences<
          _$AppDatabase,
          $AvailabilityRulesTable,
          AvailabilityRuleDbModel
        >,
      ),
      AvailabilityRuleDbModel,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$TasksTableTableManager get tasks =>
      $$TasksTableTableManager(_db, _db.tasks);
  $$GoalsTableTableManager get goals =>
      $$GoalsTableTableManager(_db, _db.goals);
  $$AvailabilityRulesTableTableManager get availabilityRules =>
      $$AvailabilityRulesTableTableManager(_db, _db.availabilityRules);
}

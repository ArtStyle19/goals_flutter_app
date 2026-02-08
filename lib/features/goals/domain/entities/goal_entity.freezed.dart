// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'goal_entity.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$GoalEntity {

 int get id; String get title; String? get description; DateTime get deadline; int get sessionDurationMinutes; List<AvailabilityRuleEntity> get availabilityRules; GoalStatus get status; int? get totalSessions; double? get totalHours; DateTime? get completedAt; DateTime get createdAt; DateTime get updatedAt; int get tasksCount; int get completedTasksCount; List<TaskEntity> get tasks;
/// Create a copy of GoalEntity
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$GoalEntityCopyWith<GoalEntity> get copyWith => _$GoalEntityCopyWithImpl<GoalEntity>(this as GoalEntity, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is GoalEntity&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.description, description) || other.description == description)&&(identical(other.deadline, deadline) || other.deadline == deadline)&&(identical(other.sessionDurationMinutes, sessionDurationMinutes) || other.sessionDurationMinutes == sessionDurationMinutes)&&const DeepCollectionEquality().equals(other.availabilityRules, availabilityRules)&&(identical(other.status, status) || other.status == status)&&(identical(other.totalSessions, totalSessions) || other.totalSessions == totalSessions)&&(identical(other.totalHours, totalHours) || other.totalHours == totalHours)&&(identical(other.completedAt, completedAt) || other.completedAt == completedAt)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.tasksCount, tasksCount) || other.tasksCount == tasksCount)&&(identical(other.completedTasksCount, completedTasksCount) || other.completedTasksCount == completedTasksCount)&&const DeepCollectionEquality().equals(other.tasks, tasks));
}


@override
int get hashCode => Object.hash(runtimeType,id,title,description,deadline,sessionDurationMinutes,const DeepCollectionEquality().hash(availabilityRules),status,totalSessions,totalHours,completedAt,createdAt,updatedAt,tasksCount,completedTasksCount,const DeepCollectionEquality().hash(tasks));

@override
String toString() {
  return 'GoalEntity(id: $id, title: $title, description: $description, deadline: $deadline, sessionDurationMinutes: $sessionDurationMinutes, availabilityRules: $availabilityRules, status: $status, totalSessions: $totalSessions, totalHours: $totalHours, completedAt: $completedAt, createdAt: $createdAt, updatedAt: $updatedAt, tasksCount: $tasksCount, completedTasksCount: $completedTasksCount, tasks: $tasks)';
}


}

/// @nodoc
abstract mixin class $GoalEntityCopyWith<$Res>  {
  factory $GoalEntityCopyWith(GoalEntity value, $Res Function(GoalEntity) _then) = _$GoalEntityCopyWithImpl;
@useResult
$Res call({
 int id, String title, String? description, DateTime deadline, int sessionDurationMinutes, List<AvailabilityRuleEntity> availabilityRules, GoalStatus status, int? totalSessions, double? totalHours, DateTime? completedAt, DateTime createdAt, DateTime updatedAt, int tasksCount, int completedTasksCount, List<TaskEntity> tasks
});




}
/// @nodoc
class _$GoalEntityCopyWithImpl<$Res>
    implements $GoalEntityCopyWith<$Res> {
  _$GoalEntityCopyWithImpl(this._self, this._then);

  final GoalEntity _self;
  final $Res Function(GoalEntity) _then;

/// Create a copy of GoalEntity
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? title = null,Object? description = freezed,Object? deadline = null,Object? sessionDurationMinutes = null,Object? availabilityRules = null,Object? status = null,Object? totalSessions = freezed,Object? totalHours = freezed,Object? completedAt = freezed,Object? createdAt = null,Object? updatedAt = null,Object? tasksCount = null,Object? completedTasksCount = null,Object? tasks = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,deadline: null == deadline ? _self.deadline : deadline // ignore: cast_nullable_to_non_nullable
as DateTime,sessionDurationMinutes: null == sessionDurationMinutes ? _self.sessionDurationMinutes : sessionDurationMinutes // ignore: cast_nullable_to_non_nullable
as int,availabilityRules: null == availabilityRules ? _self.availabilityRules : availabilityRules // ignore: cast_nullable_to_non_nullable
as List<AvailabilityRuleEntity>,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as GoalStatus,totalSessions: freezed == totalSessions ? _self.totalSessions : totalSessions // ignore: cast_nullable_to_non_nullable
as int?,totalHours: freezed == totalHours ? _self.totalHours : totalHours // ignore: cast_nullable_to_non_nullable
as double?,completedAt: freezed == completedAt ? _self.completedAt : completedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,tasksCount: null == tasksCount ? _self.tasksCount : tasksCount // ignore: cast_nullable_to_non_nullable
as int,completedTasksCount: null == completedTasksCount ? _self.completedTasksCount : completedTasksCount // ignore: cast_nullable_to_non_nullable
as int,tasks: null == tasks ? _self.tasks : tasks // ignore: cast_nullable_to_non_nullable
as List<TaskEntity>,
  ));
}

}


/// Adds pattern-matching-related methods to [GoalEntity].
extension GoalEntityPatterns on GoalEntity {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _GoalEntity value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _GoalEntity() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _GoalEntity value)  $default,){
final _that = this;
switch (_that) {
case _GoalEntity():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _GoalEntity value)?  $default,){
final _that = this;
switch (_that) {
case _GoalEntity() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  String title,  String? description,  DateTime deadline,  int sessionDurationMinutes,  List<AvailabilityRuleEntity> availabilityRules,  GoalStatus status,  int? totalSessions,  double? totalHours,  DateTime? completedAt,  DateTime createdAt,  DateTime updatedAt,  int tasksCount,  int completedTasksCount,  List<TaskEntity> tasks)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _GoalEntity() when $default != null:
return $default(_that.id,_that.title,_that.description,_that.deadline,_that.sessionDurationMinutes,_that.availabilityRules,_that.status,_that.totalSessions,_that.totalHours,_that.completedAt,_that.createdAt,_that.updatedAt,_that.tasksCount,_that.completedTasksCount,_that.tasks);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  String title,  String? description,  DateTime deadline,  int sessionDurationMinutes,  List<AvailabilityRuleEntity> availabilityRules,  GoalStatus status,  int? totalSessions,  double? totalHours,  DateTime? completedAt,  DateTime createdAt,  DateTime updatedAt,  int tasksCount,  int completedTasksCount,  List<TaskEntity> tasks)  $default,) {final _that = this;
switch (_that) {
case _GoalEntity():
return $default(_that.id,_that.title,_that.description,_that.deadline,_that.sessionDurationMinutes,_that.availabilityRules,_that.status,_that.totalSessions,_that.totalHours,_that.completedAt,_that.createdAt,_that.updatedAt,_that.tasksCount,_that.completedTasksCount,_that.tasks);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  String title,  String? description,  DateTime deadline,  int sessionDurationMinutes,  List<AvailabilityRuleEntity> availabilityRules,  GoalStatus status,  int? totalSessions,  double? totalHours,  DateTime? completedAt,  DateTime createdAt,  DateTime updatedAt,  int tasksCount,  int completedTasksCount,  List<TaskEntity> tasks)?  $default,) {final _that = this;
switch (_that) {
case _GoalEntity() when $default != null:
return $default(_that.id,_that.title,_that.description,_that.deadline,_that.sessionDurationMinutes,_that.availabilityRules,_that.status,_that.totalSessions,_that.totalHours,_that.completedAt,_that.createdAt,_that.updatedAt,_that.tasksCount,_that.completedTasksCount,_that.tasks);case _:
  return null;

}
}

}

/// @nodoc


class _GoalEntity extends GoalEntity {
  const _GoalEntity({required this.id, required this.title, this.description, required this.deadline, required this.sessionDurationMinutes, required final  List<AvailabilityRuleEntity> availabilityRules, required this.status, this.totalSessions, this.totalHours, this.completedAt, required this.createdAt, required this.updatedAt, this.tasksCount = 0, this.completedTasksCount = 0, final  List<TaskEntity> tasks = const []}): _availabilityRules = availabilityRules,_tasks = tasks,super._();
  

@override final  int id;
@override final  String title;
@override final  String? description;
@override final  DateTime deadline;
@override final  int sessionDurationMinutes;
 final  List<AvailabilityRuleEntity> _availabilityRules;
@override List<AvailabilityRuleEntity> get availabilityRules {
  if (_availabilityRules is EqualUnmodifiableListView) return _availabilityRules;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_availabilityRules);
}

@override final  GoalStatus status;
@override final  int? totalSessions;
@override final  double? totalHours;
@override final  DateTime? completedAt;
@override final  DateTime createdAt;
@override final  DateTime updatedAt;
@override@JsonKey() final  int tasksCount;
@override@JsonKey() final  int completedTasksCount;
 final  List<TaskEntity> _tasks;
@override@JsonKey() List<TaskEntity> get tasks {
  if (_tasks is EqualUnmodifiableListView) return _tasks;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_tasks);
}


/// Create a copy of GoalEntity
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$GoalEntityCopyWith<_GoalEntity> get copyWith => __$GoalEntityCopyWithImpl<_GoalEntity>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _GoalEntity&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.description, description) || other.description == description)&&(identical(other.deadline, deadline) || other.deadline == deadline)&&(identical(other.sessionDurationMinutes, sessionDurationMinutes) || other.sessionDurationMinutes == sessionDurationMinutes)&&const DeepCollectionEquality().equals(other._availabilityRules, _availabilityRules)&&(identical(other.status, status) || other.status == status)&&(identical(other.totalSessions, totalSessions) || other.totalSessions == totalSessions)&&(identical(other.totalHours, totalHours) || other.totalHours == totalHours)&&(identical(other.completedAt, completedAt) || other.completedAt == completedAt)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.tasksCount, tasksCount) || other.tasksCount == tasksCount)&&(identical(other.completedTasksCount, completedTasksCount) || other.completedTasksCount == completedTasksCount)&&const DeepCollectionEquality().equals(other._tasks, _tasks));
}


@override
int get hashCode => Object.hash(runtimeType,id,title,description,deadline,sessionDurationMinutes,const DeepCollectionEquality().hash(_availabilityRules),status,totalSessions,totalHours,completedAt,createdAt,updatedAt,tasksCount,completedTasksCount,const DeepCollectionEquality().hash(_tasks));

@override
String toString() {
  return 'GoalEntity(id: $id, title: $title, description: $description, deadline: $deadline, sessionDurationMinutes: $sessionDurationMinutes, availabilityRules: $availabilityRules, status: $status, totalSessions: $totalSessions, totalHours: $totalHours, completedAt: $completedAt, createdAt: $createdAt, updatedAt: $updatedAt, tasksCount: $tasksCount, completedTasksCount: $completedTasksCount, tasks: $tasks)';
}


}

/// @nodoc
abstract mixin class _$GoalEntityCopyWith<$Res> implements $GoalEntityCopyWith<$Res> {
  factory _$GoalEntityCopyWith(_GoalEntity value, $Res Function(_GoalEntity) _then) = __$GoalEntityCopyWithImpl;
@override @useResult
$Res call({
 int id, String title, String? description, DateTime deadline, int sessionDurationMinutes, List<AvailabilityRuleEntity> availabilityRules, GoalStatus status, int? totalSessions, double? totalHours, DateTime? completedAt, DateTime createdAt, DateTime updatedAt, int tasksCount, int completedTasksCount, List<TaskEntity> tasks
});




}
/// @nodoc
class __$GoalEntityCopyWithImpl<$Res>
    implements _$GoalEntityCopyWith<$Res> {
  __$GoalEntityCopyWithImpl(this._self, this._then);

  final _GoalEntity _self;
  final $Res Function(_GoalEntity) _then;

/// Create a copy of GoalEntity
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? title = null,Object? description = freezed,Object? deadline = null,Object? sessionDurationMinutes = null,Object? availabilityRules = null,Object? status = null,Object? totalSessions = freezed,Object? totalHours = freezed,Object? completedAt = freezed,Object? createdAt = null,Object? updatedAt = null,Object? tasksCount = null,Object? completedTasksCount = null,Object? tasks = null,}) {
  return _then(_GoalEntity(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,deadline: null == deadline ? _self.deadline : deadline // ignore: cast_nullable_to_non_nullable
as DateTime,sessionDurationMinutes: null == sessionDurationMinutes ? _self.sessionDurationMinutes : sessionDurationMinutes // ignore: cast_nullable_to_non_nullable
as int,availabilityRules: null == availabilityRules ? _self._availabilityRules : availabilityRules // ignore: cast_nullable_to_non_nullable
as List<AvailabilityRuleEntity>,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as GoalStatus,totalSessions: freezed == totalSessions ? _self.totalSessions : totalSessions // ignore: cast_nullable_to_non_nullable
as int?,totalHours: freezed == totalHours ? _self.totalHours : totalHours // ignore: cast_nullable_to_non_nullable
as double?,completedAt: freezed == completedAt ? _self.completedAt : completedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,tasksCount: null == tasksCount ? _self.tasksCount : tasksCount // ignore: cast_nullable_to_non_nullable
as int,completedTasksCount: null == completedTasksCount ? _self.completedTasksCount : completedTasksCount // ignore: cast_nullable_to_non_nullable
as int,tasks: null == tasks ? _self._tasks : tasks // ignore: cast_nullable_to_non_nullable
as List<TaskEntity>,
  ));
}


}

/// @nodoc
mixin _$AvailabilityRuleEntity {

 String get day; String get start; String get end;
/// Create a copy of AvailabilityRuleEntity
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AvailabilityRuleEntityCopyWith<AvailabilityRuleEntity> get copyWith => _$AvailabilityRuleEntityCopyWithImpl<AvailabilityRuleEntity>(this as AvailabilityRuleEntity, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AvailabilityRuleEntity&&(identical(other.day, day) || other.day == day)&&(identical(other.start, start) || other.start == start)&&(identical(other.end, end) || other.end == end));
}


@override
int get hashCode => Object.hash(runtimeType,day,start,end);

@override
String toString() {
  return 'AvailabilityRuleEntity(day: $day, start: $start, end: $end)';
}


}

/// @nodoc
abstract mixin class $AvailabilityRuleEntityCopyWith<$Res>  {
  factory $AvailabilityRuleEntityCopyWith(AvailabilityRuleEntity value, $Res Function(AvailabilityRuleEntity) _then) = _$AvailabilityRuleEntityCopyWithImpl;
@useResult
$Res call({
 String day, String start, String end
});




}
/// @nodoc
class _$AvailabilityRuleEntityCopyWithImpl<$Res>
    implements $AvailabilityRuleEntityCopyWith<$Res> {
  _$AvailabilityRuleEntityCopyWithImpl(this._self, this._then);

  final AvailabilityRuleEntity _self;
  final $Res Function(AvailabilityRuleEntity) _then;

/// Create a copy of AvailabilityRuleEntity
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? day = null,Object? start = null,Object? end = null,}) {
  return _then(_self.copyWith(
day: null == day ? _self.day : day // ignore: cast_nullable_to_non_nullable
as String,start: null == start ? _self.start : start // ignore: cast_nullable_to_non_nullable
as String,end: null == end ? _self.end : end // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [AvailabilityRuleEntity].
extension AvailabilityRuleEntityPatterns on AvailabilityRuleEntity {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AvailabilityRuleEntity value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AvailabilityRuleEntity() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AvailabilityRuleEntity value)  $default,){
final _that = this;
switch (_that) {
case _AvailabilityRuleEntity():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AvailabilityRuleEntity value)?  $default,){
final _that = this;
switch (_that) {
case _AvailabilityRuleEntity() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String day,  String start,  String end)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AvailabilityRuleEntity() when $default != null:
return $default(_that.day,_that.start,_that.end);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String day,  String start,  String end)  $default,) {final _that = this;
switch (_that) {
case _AvailabilityRuleEntity():
return $default(_that.day,_that.start,_that.end);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String day,  String start,  String end)?  $default,) {final _that = this;
switch (_that) {
case _AvailabilityRuleEntity() when $default != null:
return $default(_that.day,_that.start,_that.end);case _:
  return null;

}
}

}

/// @nodoc


class _AvailabilityRuleEntity implements AvailabilityRuleEntity {
  const _AvailabilityRuleEntity({required this.day, required this.start, required this.end});
  

@override final  String day;
@override final  String start;
@override final  String end;

/// Create a copy of AvailabilityRuleEntity
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AvailabilityRuleEntityCopyWith<_AvailabilityRuleEntity> get copyWith => __$AvailabilityRuleEntityCopyWithImpl<_AvailabilityRuleEntity>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AvailabilityRuleEntity&&(identical(other.day, day) || other.day == day)&&(identical(other.start, start) || other.start == start)&&(identical(other.end, end) || other.end == end));
}


@override
int get hashCode => Object.hash(runtimeType,day,start,end);

@override
String toString() {
  return 'AvailabilityRuleEntity(day: $day, start: $start, end: $end)';
}


}

/// @nodoc
abstract mixin class _$AvailabilityRuleEntityCopyWith<$Res> implements $AvailabilityRuleEntityCopyWith<$Res> {
  factory _$AvailabilityRuleEntityCopyWith(_AvailabilityRuleEntity value, $Res Function(_AvailabilityRuleEntity) _then) = __$AvailabilityRuleEntityCopyWithImpl;
@override @useResult
$Res call({
 String day, String start, String end
});




}
/// @nodoc
class __$AvailabilityRuleEntityCopyWithImpl<$Res>
    implements _$AvailabilityRuleEntityCopyWith<$Res> {
  __$AvailabilityRuleEntityCopyWithImpl(this._self, this._then);

  final _AvailabilityRuleEntity _self;
  final $Res Function(_AvailabilityRuleEntity) _then;

/// Create a copy of AvailabilityRuleEntity
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? day = null,Object? start = null,Object? end = null,}) {
  return _then(_AvailabilityRuleEntity(
day: null == day ? _self.day : day // ignore: cast_nullable_to_non_nullable
as String,start: null == start ? _self.start : start // ignore: cast_nullable_to_non_nullable
as String,end: null == end ? _self.end : end // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on

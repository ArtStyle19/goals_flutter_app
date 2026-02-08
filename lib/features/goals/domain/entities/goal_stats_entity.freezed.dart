// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'goal_stats_entity.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$GoalStatsEntity {

 int get totalTasks; int get completedTasks; int get skippedTasks; int get pendingTasks; double get progressPercentage; double get totalHoursPlanned; double get hoursCompleted; double get hoursRemaining; int get daysUntilDeadline; bool get onTrack;
/// Create a copy of GoalStatsEntity
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$GoalStatsEntityCopyWith<GoalStatsEntity> get copyWith => _$GoalStatsEntityCopyWithImpl<GoalStatsEntity>(this as GoalStatsEntity, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is GoalStatsEntity&&(identical(other.totalTasks, totalTasks) || other.totalTasks == totalTasks)&&(identical(other.completedTasks, completedTasks) || other.completedTasks == completedTasks)&&(identical(other.skippedTasks, skippedTasks) || other.skippedTasks == skippedTasks)&&(identical(other.pendingTasks, pendingTasks) || other.pendingTasks == pendingTasks)&&(identical(other.progressPercentage, progressPercentage) || other.progressPercentage == progressPercentage)&&(identical(other.totalHoursPlanned, totalHoursPlanned) || other.totalHoursPlanned == totalHoursPlanned)&&(identical(other.hoursCompleted, hoursCompleted) || other.hoursCompleted == hoursCompleted)&&(identical(other.hoursRemaining, hoursRemaining) || other.hoursRemaining == hoursRemaining)&&(identical(other.daysUntilDeadline, daysUntilDeadline) || other.daysUntilDeadline == daysUntilDeadline)&&(identical(other.onTrack, onTrack) || other.onTrack == onTrack));
}


@override
int get hashCode => Object.hash(runtimeType,totalTasks,completedTasks,skippedTasks,pendingTasks,progressPercentage,totalHoursPlanned,hoursCompleted,hoursRemaining,daysUntilDeadline,onTrack);

@override
String toString() {
  return 'GoalStatsEntity(totalTasks: $totalTasks, completedTasks: $completedTasks, skippedTasks: $skippedTasks, pendingTasks: $pendingTasks, progressPercentage: $progressPercentage, totalHoursPlanned: $totalHoursPlanned, hoursCompleted: $hoursCompleted, hoursRemaining: $hoursRemaining, daysUntilDeadline: $daysUntilDeadline, onTrack: $onTrack)';
}


}

/// @nodoc
abstract mixin class $GoalStatsEntityCopyWith<$Res>  {
  factory $GoalStatsEntityCopyWith(GoalStatsEntity value, $Res Function(GoalStatsEntity) _then) = _$GoalStatsEntityCopyWithImpl;
@useResult
$Res call({
 int totalTasks, int completedTasks, int skippedTasks, int pendingTasks, double progressPercentage, double totalHoursPlanned, double hoursCompleted, double hoursRemaining, int daysUntilDeadline, bool onTrack
});




}
/// @nodoc
class _$GoalStatsEntityCopyWithImpl<$Res>
    implements $GoalStatsEntityCopyWith<$Res> {
  _$GoalStatsEntityCopyWithImpl(this._self, this._then);

  final GoalStatsEntity _self;
  final $Res Function(GoalStatsEntity) _then;

/// Create a copy of GoalStatsEntity
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? totalTasks = null,Object? completedTasks = null,Object? skippedTasks = null,Object? pendingTasks = null,Object? progressPercentage = null,Object? totalHoursPlanned = null,Object? hoursCompleted = null,Object? hoursRemaining = null,Object? daysUntilDeadline = null,Object? onTrack = null,}) {
  return _then(_self.copyWith(
totalTasks: null == totalTasks ? _self.totalTasks : totalTasks // ignore: cast_nullable_to_non_nullable
as int,completedTasks: null == completedTasks ? _self.completedTasks : completedTasks // ignore: cast_nullable_to_non_nullable
as int,skippedTasks: null == skippedTasks ? _self.skippedTasks : skippedTasks // ignore: cast_nullable_to_non_nullable
as int,pendingTasks: null == pendingTasks ? _self.pendingTasks : pendingTasks // ignore: cast_nullable_to_non_nullable
as int,progressPercentage: null == progressPercentage ? _self.progressPercentage : progressPercentage // ignore: cast_nullable_to_non_nullable
as double,totalHoursPlanned: null == totalHoursPlanned ? _self.totalHoursPlanned : totalHoursPlanned // ignore: cast_nullable_to_non_nullable
as double,hoursCompleted: null == hoursCompleted ? _self.hoursCompleted : hoursCompleted // ignore: cast_nullable_to_non_nullable
as double,hoursRemaining: null == hoursRemaining ? _self.hoursRemaining : hoursRemaining // ignore: cast_nullable_to_non_nullable
as double,daysUntilDeadline: null == daysUntilDeadline ? _self.daysUntilDeadline : daysUntilDeadline // ignore: cast_nullable_to_non_nullable
as int,onTrack: null == onTrack ? _self.onTrack : onTrack // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [GoalStatsEntity].
extension GoalStatsEntityPatterns on GoalStatsEntity {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _GoalStatsEntity value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _GoalStatsEntity() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _GoalStatsEntity value)  $default,){
final _that = this;
switch (_that) {
case _GoalStatsEntity():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _GoalStatsEntity value)?  $default,){
final _that = this;
switch (_that) {
case _GoalStatsEntity() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int totalTasks,  int completedTasks,  int skippedTasks,  int pendingTasks,  double progressPercentage,  double totalHoursPlanned,  double hoursCompleted,  double hoursRemaining,  int daysUntilDeadline,  bool onTrack)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _GoalStatsEntity() when $default != null:
return $default(_that.totalTasks,_that.completedTasks,_that.skippedTasks,_that.pendingTasks,_that.progressPercentage,_that.totalHoursPlanned,_that.hoursCompleted,_that.hoursRemaining,_that.daysUntilDeadline,_that.onTrack);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int totalTasks,  int completedTasks,  int skippedTasks,  int pendingTasks,  double progressPercentage,  double totalHoursPlanned,  double hoursCompleted,  double hoursRemaining,  int daysUntilDeadline,  bool onTrack)  $default,) {final _that = this;
switch (_that) {
case _GoalStatsEntity():
return $default(_that.totalTasks,_that.completedTasks,_that.skippedTasks,_that.pendingTasks,_that.progressPercentage,_that.totalHoursPlanned,_that.hoursCompleted,_that.hoursRemaining,_that.daysUntilDeadline,_that.onTrack);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int totalTasks,  int completedTasks,  int skippedTasks,  int pendingTasks,  double progressPercentage,  double totalHoursPlanned,  double hoursCompleted,  double hoursRemaining,  int daysUntilDeadline,  bool onTrack)?  $default,) {final _that = this;
switch (_that) {
case _GoalStatsEntity() when $default != null:
return $default(_that.totalTasks,_that.completedTasks,_that.skippedTasks,_that.pendingTasks,_that.progressPercentage,_that.totalHoursPlanned,_that.hoursCompleted,_that.hoursRemaining,_that.daysUntilDeadline,_that.onTrack);case _:
  return null;

}
}

}

/// @nodoc


class _GoalStatsEntity implements GoalStatsEntity {
  const _GoalStatsEntity({required this.totalTasks, required this.completedTasks, required this.skippedTasks, required this.pendingTasks, required this.progressPercentage, required this.totalHoursPlanned, required this.hoursCompleted, required this.hoursRemaining, required this.daysUntilDeadline, required this.onTrack});
  

@override final  int totalTasks;
@override final  int completedTasks;
@override final  int skippedTasks;
@override final  int pendingTasks;
@override final  double progressPercentage;
@override final  double totalHoursPlanned;
@override final  double hoursCompleted;
@override final  double hoursRemaining;
@override final  int daysUntilDeadline;
@override final  bool onTrack;

/// Create a copy of GoalStatsEntity
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$GoalStatsEntityCopyWith<_GoalStatsEntity> get copyWith => __$GoalStatsEntityCopyWithImpl<_GoalStatsEntity>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _GoalStatsEntity&&(identical(other.totalTasks, totalTasks) || other.totalTasks == totalTasks)&&(identical(other.completedTasks, completedTasks) || other.completedTasks == completedTasks)&&(identical(other.skippedTasks, skippedTasks) || other.skippedTasks == skippedTasks)&&(identical(other.pendingTasks, pendingTasks) || other.pendingTasks == pendingTasks)&&(identical(other.progressPercentage, progressPercentage) || other.progressPercentage == progressPercentage)&&(identical(other.totalHoursPlanned, totalHoursPlanned) || other.totalHoursPlanned == totalHoursPlanned)&&(identical(other.hoursCompleted, hoursCompleted) || other.hoursCompleted == hoursCompleted)&&(identical(other.hoursRemaining, hoursRemaining) || other.hoursRemaining == hoursRemaining)&&(identical(other.daysUntilDeadline, daysUntilDeadline) || other.daysUntilDeadline == daysUntilDeadline)&&(identical(other.onTrack, onTrack) || other.onTrack == onTrack));
}


@override
int get hashCode => Object.hash(runtimeType,totalTasks,completedTasks,skippedTasks,pendingTasks,progressPercentage,totalHoursPlanned,hoursCompleted,hoursRemaining,daysUntilDeadline,onTrack);

@override
String toString() {
  return 'GoalStatsEntity(totalTasks: $totalTasks, completedTasks: $completedTasks, skippedTasks: $skippedTasks, pendingTasks: $pendingTasks, progressPercentage: $progressPercentage, totalHoursPlanned: $totalHoursPlanned, hoursCompleted: $hoursCompleted, hoursRemaining: $hoursRemaining, daysUntilDeadline: $daysUntilDeadline, onTrack: $onTrack)';
}


}

/// @nodoc
abstract mixin class _$GoalStatsEntityCopyWith<$Res> implements $GoalStatsEntityCopyWith<$Res> {
  factory _$GoalStatsEntityCopyWith(_GoalStatsEntity value, $Res Function(_GoalStatsEntity) _then) = __$GoalStatsEntityCopyWithImpl;
@override @useResult
$Res call({
 int totalTasks, int completedTasks, int skippedTasks, int pendingTasks, double progressPercentage, double totalHoursPlanned, double hoursCompleted, double hoursRemaining, int daysUntilDeadline, bool onTrack
});




}
/// @nodoc
class __$GoalStatsEntityCopyWithImpl<$Res>
    implements _$GoalStatsEntityCopyWith<$Res> {
  __$GoalStatsEntityCopyWithImpl(this._self, this._then);

  final _GoalStatsEntity _self;
  final $Res Function(_GoalStatsEntity) _then;

/// Create a copy of GoalStatsEntity
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? totalTasks = null,Object? completedTasks = null,Object? skippedTasks = null,Object? pendingTasks = null,Object? progressPercentage = null,Object? totalHoursPlanned = null,Object? hoursCompleted = null,Object? hoursRemaining = null,Object? daysUntilDeadline = null,Object? onTrack = null,}) {
  return _then(_GoalStatsEntity(
totalTasks: null == totalTasks ? _self.totalTasks : totalTasks // ignore: cast_nullable_to_non_nullable
as int,completedTasks: null == completedTasks ? _self.completedTasks : completedTasks // ignore: cast_nullable_to_non_nullable
as int,skippedTasks: null == skippedTasks ? _self.skippedTasks : skippedTasks // ignore: cast_nullable_to_non_nullable
as int,pendingTasks: null == pendingTasks ? _self.pendingTasks : pendingTasks // ignore: cast_nullable_to_non_nullable
as int,progressPercentage: null == progressPercentage ? _self.progressPercentage : progressPercentage // ignore: cast_nullable_to_non_nullable
as double,totalHoursPlanned: null == totalHoursPlanned ? _self.totalHoursPlanned : totalHoursPlanned // ignore: cast_nullable_to_non_nullable
as double,hoursCompleted: null == hoursCompleted ? _self.hoursCompleted : hoursCompleted // ignore: cast_nullable_to_non_nullable
as double,hoursRemaining: null == hoursRemaining ? _self.hoursRemaining : hoursRemaining // ignore: cast_nullable_to_non_nullable
as double,daysUntilDeadline: null == daysUntilDeadline ? _self.daysUntilDeadline : daysUntilDeadline // ignore: cast_nullable_to_non_nullable
as int,onTrack: null == onTrack ? _self.onTrack : onTrack // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on

public enum PlayerState
{
	Dash,
	Move,
	Idle,
	Jump,
	Stun,
	Damage,
}

public enum ActionControle
{
	MoveForward,
	MoveRight,
	Jump,
	Dash
}

public enum CharaBonus
{
	Speed,
	Acceleration,

	Rotate,

	AirControle,
	AirControleAcceleration,

	StopMovement,
	StopMovementAcceleration
}

public enum TypeUseState
{
	Stay,
	CloseWhenFinish,
}
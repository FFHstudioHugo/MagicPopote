using UnityEngine;

public class StateCharacterMove : StateCharacter
{
	#region Variables
	public override PlayerState P_State
	{
		get
		{
			return PlayerState.Move;
		}
	}

	[SerializeField] CharacterMoveScriptable thisCharaMove;
	[SerializeField] Transform cameraTransform;

	[HideInInspector] public Vector3 TargetDirection;
	CharacterGravity charaGrav;

	Vector2 rangeCurveAcc;
	Vector2 rangeCurveStop;

	Vector3 lastMove;
	float lastSpeedRotate = 0;

	float forwardInput = 0;
	float rightInput = 0;

	float currPourControl = 0;
	float currStop = 0;
	float currAcc = 0;

	float bonusAcceleration = 1;
	float bonusStopMovement = 1;
	float bonusAirControle = 1;
	float bonusRotate = 1;
	float bonusSpeed = 1;

	float bonusStopMovementAcceleration = 1;
	float bonusAirControleAcceleration = 1;
	#endregion

	#region Mono
	void FixedUpdate ( )
	{
		movePlayer (rightInput, forwardInput);
	}
	#endregion

	#region Public Methodes
	public override void IniChara ( )
	{
		base.IniChara ( );
		charaGrav = GetComponent<CharacterGravity> ( );

		rangeCurveAcc = new Vector2 (thisCharaMove.curveAcceleration.keys [0].time, thisCharaMove.curveAcceleration.keys [thisCharaMove.curveAcceleration.keys.Length - 1].time);
		rangeCurveStop = new Vector2 (thisCharaMove.curveStop.keys [0].time, thisCharaMove.curveStop.keys [thisCharaMove.curveStop.keys.Length - 1].time);
	}

	public override bool OpenState ( )
	{
		base.OpenState ( );

		currPourControl = 0;
		currStop = 0;
		currAcc = 0;
		bonusAcceleration = 1;

		bonusStopMovement = 1;
		bonusAirControle = 1;
		bonusRotate = 1;
		bonusSpeed = 1;

		bonusStopMovementAcceleration = 1;
		bonusAirControleAcceleration = 1;

		return true;
	}

	public override void CloseState ( )
	{
		base.CloseState ( );
	}

	public void MoveCharacter (float Axis, ActionControle thisAction)
	{
		if (thisAction == ActionControle.MoveForward)
		{
			forwardInput = Axis;
		}
		else
		{
			rightInput = Axis;
		}
	}

	public void AddBonus (CharaBonus bonusType, float bonusMultipli, float time)
	{

	}
	#endregion
	#region Private Methodes
	void movePlayer (float inputX, float inputY)
	{
		float getTime = Time.deltaTime;

		Vector3 currMove = cameraTransform.forward * inputY;
		currMove += cameraTransform.right * inputX;
		currMove = new Vector3 (currMove.x, 0, currMove.z);

		if (currMove.magnitude > 1)
		{
			currMove /= currMove.magnitude;
		}

		currMove -= angleGround (currMove);

		float magnitudeInput = Mathf.Clamp (new Vector2 (inputX, inputY).magnitude, 0, 1);
		float angleDirection = Vector3.Angle (thisTrans.forward, currMove.normalized) / 180;
		currMove -= currMove * angleDirection * thisCharaMove.PourcBackward;

		TargetDirection = currMove;

		if ((inputX != 0 || inputY != 0)
			&& (rotatePlayer (getTime, currMove) < thisCharaMove.AngleSlowDown || currAcc < (rangeCurveAcc.x + rangeCurveAcc.y * 0.2f)))
		{
			if (currAcc < rangeCurveAcc.y * magnitudeInput)
			{
				currAcc += getTime * bonusAcceleration;
			}
			else
			{
				currAcc = rangeCurveAcc.y * magnitudeInput;
			}

			currAcc = Mathf.Clamp (currAcc, 0, rangeCurveAcc.y);
			currStop = (rangeCurveStop.y - rangeCurveStop.y * (currAcc / rangeCurveAcc.y));
			currMove *= getTime * thisCharaMove.MoveSpeed * bonusSpeed * thisCharaMove.curveAcceleration.Evaluate (currAcc);
		}
		else
		{
			currStop += getTime * bonusStopMovementAcceleration;
			currStop = Mathf.Clamp (currStop, 0, rangeCurveStop.y);

			currAcc = rangeCurveAcc.y - rangeCurveAcc.y * (currStop / rangeCurveStop.y);
			currMove = Vector3.Lerp (lastMove, currMove, getTime * thisCharaMove.curveStop.Evaluate (currStop) * bonusStopMovement);
		}

		if (!charaGrav.OnGround)
		{
			currMove = Vector3.Lerp (lastMove, currMove, getTime * thisCharaMove.SmoothSlowAirControl.Evaluate (currPourControl) * bonusAirControle);
			currPourControl += getTime * bonusAirControleAcceleration;
		}
		else
		{
			currPourControl = 0;
		}

		lastMove = currMove;

		thisRig.MovePosition (thisTrans.position += currMove);
	}

	float rotatePlayer (float getTime, Vector3 currMove)
	{
		currMove = currMove.normalized;
		currMove = new Vector3 (currMove.x, 0, currMove.z);

		Quaternion newAngle = Quaternion.LookRotation (currMove, thisTrans.up);
		float getAngle = Quaternion.Angle (newAngle, thisTrans.localRotation) / 180;
		float speedRotate = (thisCharaMove.RotationSpeed - thisCharaMove.RotationSpeed * getAngle * thisCharaMove.PourSlowAngle);

		/*if (!charaGrav.OnGround)
		{
			speedRotate = Mathf.Lerp (lastSpeedRotate, speedRotate, getTime * thisCharaMove.SmoothSlowAirControl.Evaluate (currPourControl) * bonusAirControle);
		}*/

		thisTrans.localRotation = Quaternion.Lerp (thisTrans.localRotation, newAngle, speedRotate * bonusRotate * getTime);

		return getAngle;
	}

	Vector3 angleGround (Vector3 currMove)
	{
		if (charaGrav.OnGround)
		{
			return charaGrav.NormalGround * Vector3.Dot (currMove, charaGrav.NormalGround);
		}

		return Vector3.zero;
	}
	#endregion
}
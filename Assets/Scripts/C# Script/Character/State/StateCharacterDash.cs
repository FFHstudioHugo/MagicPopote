using UnityEngine;

[RequireComponent (typeof (StateCharacterMove))]
public class StateCharacterDash : StateCharacter
{
	#region Variables
	public override PlayerState P_State
	{
		get
		{
			return PlayerState.Dash;
		}
	}

	[SerializeField] CharacterDashScriptable thisCharaDash;
	CharacterGravity charaGrav;

	Vector3 saveDir = Vector3.zero;
	Vector2 rangeCurveDash;

	float currDashTime = 0;
	float getTime = -10;
	int currDash = 0;
	#endregion

	#region Mono
	void FixedUpdate ( )
	{
		float getTime = Time.fixedDeltaTime;

		Vector3 dir = saveDir - angleGround (saveDir);
		Quaternion newAngle = Quaternion.LookRotation (new Vector3 (dir.x, 0, dir.z), thisTrans.up);
		thisTrans.localRotation = Quaternion.Slerp (thisTrans.localRotation, newAngle, thisCharaDash.RotateSpeed * getTime * thisCharaDash.RotateSpeed);

		currDashTime += getTime;

		Vector3 newMove = dir * getTime * thisCharaDash.curveDash.Evaluate (currDashTime) * thisCharaDash.DashSpeed;

		thisRig.MovePosition (thisTrans.localPosition += newMove);

		if (currDashTime > rangeCurveDash.y || Physics.Raycast (thisTrans.localPosition, thisTrans.forward, 0.1f))
		{
			forceCloseState ( );
			getTime = Time.timeSinceLevelLoad;
		}

	}
	#endregion

	#region Public Methodes
	public override void IniChara ( )
	{
		base.IniChara ( );
		charaGrav = GetComponent<CharacterGravity> ( );
		rangeCurveDash = new Vector2 (thisCharaDash.curveDash.keys [0].time, thisCharaDash.curveDash.keys [thisCharaDash.curveDash.keys.Length - 1].time);
	}

	public override bool OpenState ( )
	{
		if (Time.timeSinceLevelLoad - getTime > thisCharaDash.CooldownDash || GetComponent<CharacterGravity> ( ).OnGround)
		{
			currDash = 0;
		}
		else if (currDash > thisCharaDash.NbrDashAvailable)
		{
			return false;
		}

		base.OpenState ( );

		return true;
	}

	public override void CloseState ( )
	{
		base.CloseState ( );
		GetComponent<CharacterGravity> ( ).ResetGravity (true);
	}

	public void DashChara ( )
	{
		if (currDash > thisCharaDash.NbrDashAvailable)
		{
			return;
		}

		getTime = Time.timeSinceLevelLoad;

		currDash++;
		currDashTime = 0;
		saveDir = GetComponent<StateCharacterMove> ( ).TargetDirection;

		if (saveDir.x == 0 && saveDir.z == 0)
		{
			saveDir = thisTrans.forward;
		}
		GetComponent<CharacterGravity> ( ).ResetGravity (false);
	}
	#endregion

	#region Private Methodes
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
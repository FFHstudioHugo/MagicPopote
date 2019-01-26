using UnityEngine;

[RequireComponent (typeof (CharacterGravity))]
public class StateCharacterJump : StateCharacter
{
	#region Variables
	public override PlayerState P_State
	{
		get
		{
			return PlayerState.Jump;
		}
	}

	[SerializeField] CharacterJumpScriptable thisCharaJump;

	Vector2 rangeCurveJump;

	float currJumpTime = 0;
	int currJump = 0;
	#endregion

	#region Mono

	void FixedUpdate ( )
	{
		float getTime = Time.fixedDeltaTime;

		currJumpTime += getTime;
		Vector3 newMove = Vector3.up * getTime * thisCharaJump.curveJump.Evaluate (currJumpTime) * thisCharaJump.JumpSpeed;

		if (currJumpTime > rangeCurveJump.y)
		{
			forceCloseState ( );
		}

		thisRig.velocity += newMove;
	}
	#endregion

	#region Public Methodes
	public override void IniChara ( )
	{
		base.IniChara ( );
		rangeCurveJump = new Vector2 (thisCharaJump.curveJump.keys [0].time, thisCharaJump.curveJump.keys [thisCharaJump.curveJump.keys.Length - 1].time);
	}

	public override bool OpenState ( )
	{
		if (GetComponent<CharacterGravity> ( ).OnGround)
		{
			currJump = 0;
		}
		else if (currJump >= thisCharaJump.NbrJumpAvailable)
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

	public void JumpChara ( )
	{
		if (currJump >= thisCharaJump.NbrJumpAvailable)
		{
			return;
		}

		currJump++;
		currJumpTime = 0;
		GetComponent<CharacterGravity> ( ).ResetGravity (false);
	}
	#endregion

	#region Private Methodes

	#endregion
}
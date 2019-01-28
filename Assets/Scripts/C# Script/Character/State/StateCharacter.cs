using UnityEngine;

public abstract class StateCharacter : MonoBehaviour
{
	#region Variables
	public abstract PlayerState P_State
	{
		get;
	}

	protected Transform thisTrans;
	protected Rigidbody thisRig;
	protected bool isActive;

	#endregion

	#region Mono
	#endregion

	#region Public Methodes
	public virtual bool OpenState ( )
	{
		this.enabled = true;
		isActive = true;

		return true;
	}

	public virtual void CloseState ( )
	{
		this.enabled = false;
		isActive = false;
	}

	public virtual void IniChara ( )
	{
		thisTrans = transform;
		thisRig = GetComponent<Rigidbody> ( );
	}
	#endregion

	#region Private Methodes
	protected void forceCloseState ( )
	{
		GetComponent<CharacterInput> ( ).CloseThisState (P_State);
	}
	#endregion
}
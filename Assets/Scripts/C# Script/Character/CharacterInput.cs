using System.Collections.Generic;

using UnityEngine;
using UnityEngine.Events;

public class CharacterInput : MonoBehaviour
{
	#region Variables
	public inputEvnt [ ] AllInputEvents;
	public StateEvnt [ ] AllStateEvents;

	[SerializeField]
	float deadZone;

	Dictionary<PlayerState, StateInfo> StateChara;
	List<PlayerState> currStates;

	struct StateInfo
	{
		public StateCharacter ThisChara;
		public StateEvnt stateInfo;
	}

	[System.Serializable]
	public struct StateEvnt
	{
		public PlayerState ThisState;

		public PlayerState [ ] CanCombineWith;
		public PlayerState [ ] CanBeEraseByWith;

		public UnityEvent ThisOpenEvent;
		public UnityEvent ThisCloseEvent;
	}

	[System.Serializable]
	public struct inputEvnt
	{
		public string ThisInput;
		public bool AxisInput;
		public ActionControle ThisAction;
	}
	#endregion

	#region Mono
	void Awake ( )
	{
		currStates = new List<PlayerState> ( );
		StateChara = new Dictionary<PlayerState, StateInfo> (System.Enum.GetValues (typeof (PlayerState)).Length);
		int length = AllStateEvents.Length;

		StateCharacter [ ] getComp = GetComponents<StateCharacter> ( );
		length = getComp.Length;
		int lengthState = AllStateEvents.Length;

		StateInfo checkDouble;
		for (int a = 0; a < length; a++)
		{
			if (!StateChara.TryGetValue (getComp [a].P_State, out checkDouble))
			{
				checkDouble = new StateInfo ( );
				checkDouble.ThisChara = getComp [a];

				for (int b = 0; b < lengthState; b++)
				{
					if (AllStateEvents [b].ThisState == checkDouble.ThisChara.P_State)
					{
						checkDouble.stateInfo = AllStateEvents [b];
						break;
					}
				}

				StateChara.Add (getComp [a].P_State, checkDouble);
			}

			getComp [a].IniChara ( );
			getComp [a].enabled = false;
		}

		if (StateChara.TryGetValue (PlayerState.Idle, out checkDouble))
		{
			checkNewState (checkDouble);
		}
	}

	void Update ( )
	{
		int length = AllInputEvents.Length;

		float value = 0;
		for (int a = 0; a < length; a++)
		{
			if (AllInputEvents [a].AxisInput)
			{
				value = Input.GetAxis (AllInputEvents [a].ThisInput);

				if (Mathf.Abs (value) < deadZone)
				{
					value = 0;
				}

				checkState (AllInputEvents [a], value);
			}
			else
			{
				if (Input.GetButtonDown (AllInputEvents [a].ThisInput))
				{
					value = 1;
					checkState (AllInputEvents [a], 1);
				}
				/*else if (Input.GetButtonUp (AllInputEvents [a].ThisInput))
				{
					value = -1;
				}*/
			}
		}
	}

	#endregion

	#region Public Methodes
	public void CloseThisState (PlayerState thisState)
	{
		if (currStates.Contains (thisState))
		{
			StateInfo thisInfoState;
			if (StateChara.TryGetValue (thisState, out thisInfoState))
			{
				thisInfoState.ThisChara.CloseState ( );
				thisInfoState.stateInfo.ThisCloseEvent.Invoke ( );
			}

			currStates.Remove (thisState);
		}
	}
	#endregion

	#region Private Methodes
	void checkState (inputEvnt thisEvnt, float value)
	{
		StateInfo checkDouble;
		if (!getState (thisEvnt.ThisAction, out checkDouble))
		{
			return;
		}

		if (checkNewState (checkDouble))
		{
			switch (checkDouble.stateInfo.ThisState)
			{
				case PlayerState.Move:
					StateCharacterMove charaMove = (StateCharacterMove)checkDouble.ThisChara;
					charaMove.MoveCharacter (value, thisEvnt.ThisAction);
					break;
				case PlayerState.Jump:
					StateCharacterJump charaJump = (StateCharacterJump)checkDouble.ThisChara;
					charaJump.JumpChara ( );
					break;
				case PlayerState.Dash:
					StateCharacterDash charaDash = (StateCharacterDash)checkDouble.ThisChara;
					charaDash.DashChara ( );
					break;
				default:
					break;
			}
		}
	}

	bool checkNewState (StateInfo currInfo)
	{
		if (currStates.Contains (currInfo.stateInfo.ThisState))
		{
			if (checkCombineState (currInfo.stateInfo.ThisState))
			{
				currInfo.stateInfo.ThisOpenEvent.Invoke ( );
			}

			return true;
		}
		else if (!checkCombineState (currInfo.stateInfo.ThisState, true))
		{
			return false;
		}

		if (currInfo.ThisChara.OpenState ( ))
		{
			currStates.Add (currInfo.stateInfo.ThisState);

			currInfo.stateInfo.ThisOpenEvent.Invoke ( );
			return true;
		}

		return false;
	}

	bool getState (ActionControle thisControle, out StateInfo thisChara)
	{
		PlayerState thisState;
		switch (thisControle)
		{
			case ActionControle.MoveForward:
			case ActionControle.MoveRight:
				thisState = PlayerState.Move;
				break;
			case ActionControle.Dash:
				thisState = PlayerState.Dash;
				break;
			case ActionControle.Jump:
				thisState = PlayerState.Jump;
				break;
			default:
				thisState = PlayerState.Idle;
				break;
		}

		return StateChara.TryGetValue (thisState, out thisChara);
	}

	bool checkCombineState (PlayerState thisState, bool closeState = false)
	{
		if (currStates.Count == 0)
		{
			return true;
		}

		StateInfo currState;
		int length = currStates.Count;
		for (int a = 0; a < length; a++)
		{
			if (StateChara.TryGetValue (currStates [a], out currState))
			{
				bool checkContain = false;
				int lengthCombine = currState.stateInfo.CanCombineWith.Length;
				for (int b = 0; b < currState.stateInfo.CanCombineWith.Length; b++)
				{
					if (currState.stateInfo.CanCombineWith [b] == thisState)
					{
						checkContain = true;
						break;
					}
				}

				if (!checkContain)
				{
					lengthCombine = currState.stateInfo.CanBeEraseByWith.Length;
					for (int b = 0; b < currState.stateInfo.CanBeEraseByWith.Length; b++)
					{
						if (currState.stateInfo.CanBeEraseByWith [b] == thisState)
						{
							checkContain = true;
							break;
						}
					}

					if (checkContain)
					{
						CloseThisState (currStates [a]);
						length--;
						a--;
					}
					else
					{
						return false;
					}
				}
			}
		}

		return true;
	}
	#endregion
}
using UnityEngine;

public class CharacterGravity : MonoBehaviour
{
	#region Variables
	[SerializeField] CharacterGravityScriptable thisCharaGrav;

	public bool OnGround;
	[HideInInspector] public Vector3 NormalGround;

	Transform thisTrans;
	Rigidbody thisRig;

	Vector2 rangeCurveFall;

	int nbrEnable = 0;

	float currFall = 0;
	bool lastGround = false;
	#endregion

	#region Mono
	void Awake ( )
	{
		thisTrans = transform;
		thisRig = GetComponent<Rigidbody> ( );
		rangeCurveFall = new Vector2 (thisCharaGrav.curvefall.keys [0].time, thisCharaGrav.curvefall.keys [thisCharaGrav.curvefall.keys.Length - 1].time);
	}

	void FixedUpdate ( )
	{
		RaycastHit hit;
		OnGround = Physics.Raycast (thisTrans.position + Vector3.up * 0.5f, -Vector3.up, out hit, 1, 1 << LayerMask.NameToLayer ("Ground")); //GameManger.LAYER_GROUND);
		Debug.DrawLine (thisTrans.position + Vector3.up * 0.5f, thisTrans.position - Vector3.up, Color.red, 1);

		if (lastGround != OnGround)
		{
			lastGround = OnGround;
			if (OnGround)
			{
				currFall = 0;
			}

			thisRig.useGravity = OnGround;
		}

		if (OnGround)
		{
			NormalGround = hit.normal;
		}
		else if (!OnGround)
		{
			currFall += Time.fixedDeltaTime;

			NormalGround = Vector3.zero;
			thisRig.velocity -= Vector3.up * Time.deltaTime * thisCharaGrav.curvefall.Evaluate (currFall) * thisCharaGrav.ForceFall;
		}
	}
	#endregion

	#region Public Methodes
	public void ResetGravity (bool enable)
	{
		bool checkReset = false;
		if (enable)
		{
			nbrEnable++;

			if (nbrEnable >= 0)
			{
				checkReset = true;
			}
		}
		else
		{
			thisRig.useGravity = false;
			thisRig.velocity = Vector3.zero;

			checkReset = true;
			nbrEnable--;
		}

		if (checkReset)
		{
			this.enabled = enable;
			currFall = 0;
		}
	}
	#endregion

	#region Private Methodes

	#endregion
}
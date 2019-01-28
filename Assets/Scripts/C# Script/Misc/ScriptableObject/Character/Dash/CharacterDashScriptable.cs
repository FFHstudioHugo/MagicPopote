using UnityEngine;

[CreateAssetMenu (fileName = "CharaScriptDash", menuName = "Scriptable/Character/Dash")]
public class CharacterDashScriptable : ScriptableObject
{
	public float DashSpeed;
	public float CooldownDash;
	public int NbrDashAvailable = 2;
	public AnimationCurve curveDash;

	public float RotateSpeed = 2;
}
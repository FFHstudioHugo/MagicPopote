using UnityEngine;

[CreateAssetMenu (fileName = "CharaScriptGravity", menuName = "Scriptable/Character/Gravity")]
public class CharacterGravityScriptable : ScriptableObject
{
	[Header ("Fall")]
	public AnimationCurve curvefall;
	public float ForceFall = 0.5f;
}
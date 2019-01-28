using UnityEngine;

[CreateAssetMenu (fileName = "CharaScriptJump", menuName = "Scriptable/Character/Jump")]
public class CharacterJumpScriptable : ScriptableObject
{
	[Header ("Jump")]
	public float JumpSpeed = 5;
	public int NbrJumpAvailable = 2;
	public AnimationCurve curveJump;
}
using UnityEngine;

[CreateAssetMenu (fileName = "CharaScriptMove", menuName = "Scriptable/Character/Move")]
public class CharacterMoveScriptable : ScriptableObject
{
	[Space]
	public float MoveSpeed;

	public AnimationCurve curveAcceleration;
	public AnimationCurve SmoothSlowAirControl;
	[Space]

	[Space]
	[Range (0, 1)] [Tooltip ("Pourcentage du ralentissement du movespeed entre la direction de movement et la direction ou le personnage est entrain de regarder")]
	public float PourcBackward;
	public AnimationCurve curveStop;

	[Header ("Rotation")]
	public float RotationSpeed;
	[Range (0, 1)] [Tooltip ("Pourcentage de la longeur en plus pour se retourner en proportion à l'angle ciblé (0 a 180)")]
	public float AngleSlowDown = 0.35f;
	[Range (0, 1)] [Tooltip ("Pourcentage de la longeur en plus pour se retourner en proportion à l'angle ciblé (0 a 180)")]
	public float PourSlowAngle = 0.75f;
}
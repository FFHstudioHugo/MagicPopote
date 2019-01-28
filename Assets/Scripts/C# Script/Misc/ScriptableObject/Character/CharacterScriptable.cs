using UnityEngine;

[CreateAssetMenu (fileName = "CharaScript", menuName = "Scriptable/Character")]
public class CharacterScriptable : ScriptableObject
{
    [Space]
	public float MoveSpeed;

	public AnimationCurve curveAcceleration;
    [Range (0, 1)][Tooltip ("Pourcentage sur la vitesse de course pour indiquer que le personnage est entrain de courir ou non")]
	public float PourcRun;
    public AnimationCurve SmoothSlowAirControl;
	[Space]

	[Space]
	public float DashSpeed;
	public float BonusRotateSpeed = 2;
	public float CooldownDash;
	public AnimationCurve curveDash;

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

	[Header ("Jump")]
	public float JumpSpeed = 5;
	public AnimationCurve curveJump;
	[Space]
	[Header ("Fall")]
	public AnimationCurve curvefall;
    public float ForceFall = 0.5f;
    public float VelocityToCrouch = 0.5f;
    public float TimeCrouch = 0.1f;

	[Header ("Other ")]
	public float deadZone;
}

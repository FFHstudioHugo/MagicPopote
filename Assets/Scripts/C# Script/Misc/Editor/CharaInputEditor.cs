using System.Collections.Generic;

using UnityEditor;

using UnityEngine;
using UnityEngine.Events;

[CustomEditor (typeof (CharacterInput))]
public class CharInputEditor : Editor
{
	//SerializedProperty test;

	public void OnEnable ( )
	{
		//test = serializedObject.FindProperty ("test");
	}

	public void OnDisable ( )
	{
		CharacterInput myTarget = (CharacterInput)target;

		List<CharacterInput.StateEvnt> currInput = new List<CharacterInput.StateEvnt> (myTarget.AllStateEvents);

		for (int a = 0; a < currInput.Count; a++)
		{
			for (int b = 0; b < currInput.Count; b++)
			{
				if (currInput [a].ThisState == currInput [b].ThisState && a != b)
				{
					currInput.RemoveAt (a);
					myTarget.AllStateEvents = currInput.ToArray ( );
					Debug.LogError ("There is already an element with this State");
					a = 0;
					b = 0;
				}
			}
		}
	}

	public override void OnInspectorGUI ( )
	{
		DrawDefaultInspector ( );

	}
}
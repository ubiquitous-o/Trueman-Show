using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UIElements;

public sealed class PhoneChatController
{
    private readonly Label _label;

    public PhoneChatController(VisualElement visualElement){
        _label = visualElement.Q<Label>("ChatContent");
    }
    public void SetText(string text){
        _label.text = text;
    }
}

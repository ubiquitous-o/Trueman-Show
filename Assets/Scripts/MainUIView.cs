using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UIElements;

public sealed class MainUIView : MonoBehaviour
{
    [SerializeField]
    private VisualTreeAsset _elementTemplate;
    private UIDocument uiDocument;
    private List<string> labelTexts;

    private int MAX_CHAT_COUNT = 10;


    private void OnEnable()
    {
        uiDocument = GetComponent<UIDocument>();
        labelTexts = new List<string>(){
            "test",
            "test1aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
            "test2"
        };
        new PhoneListController(uiDocument.rootVisualElement, _elementTemplate, labelTexts);
    }
    public void UpdateChatText(string text){
            labelTexts.Add(text);
            new PhoneListController(uiDocument.rootVisualElement, _elementTemplate, labelTexts);
            if (labelTexts.Count == MAX_CHAT_COUNT){
                labelTexts.RemoveAt(0);
            }

    }
}

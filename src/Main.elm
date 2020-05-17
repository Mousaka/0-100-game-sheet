module Main exposing (main)

import Browser
import Element exposing (..)
import Element.Background
import Element.Border
import Element.Events
import Element.Input
import Html exposing (Html)
import Html.Attributes


type alias Answer =
    { oneIndex : Int
    , yourAnswer : Maybe Int
    , diff : Maybe Int
    }


type alias Model =
    { name : String
    , answers : List Answer
    , partSum1 : String
    , partSum2 : String
    , partSum3 : String
    , totalSum : String
    }


initAnswer : Int -> Answer
initAnswer i =
    Answer i Nothing Nothing


initialModel : Model
initialModel =
    { name = ""
    , answers = List.range 1 21 |> List.map initAnswer
    , partSum1 = ""
    , partSum2 = ""
    , partSum3 = ""
    , totalSum = ""
    }


type Msg
    = AnswerGiven Int String
    | DiffGiven Int String
    | ChangedPartSum1 String
    | ChangedPartSum2 String
    | ChangedPartSum3 String
    | ChangedTotalSum String


update : Msg -> Model -> Model
update msg model =
    case msg of
        AnswerGiven index answer ->
            { model
                | answers =
                    List.map
                        (\a ->
                            if a.oneIndex == index then
                                { a
                                    | yourAnswer =
                                        case answer |> String.toInt of
                                            Nothing ->
                                                if answer == "" then
                                                    Nothing

                                                else
                                                    a.yourAnswer

                                            Just ans ->
                                                Just (clamp 0 100 ans)
                                }

                            else
                                a
                        )
                        model.answers
            }

        ChangedPartSum1 sum ->
            { model | partSum1 = sum }

        ChangedPartSum2 sum ->
            { model | partSum2 = sum }

        ChangedPartSum3 sum ->
            { model | partSum3 = sum }

        ChangedTotalSum sum ->
            { model | totalSum = sum }

        DiffGiven index answer ->
            { model
                | answers =
                    List.map
                        (\a ->
                            if a.oneIndex == index then
                                { a
                                    | diff =
                                        case answer |> String.toInt of
                                            Nothing ->
                                                Nothing

                                            Just ans ->
                                                Just (clamp -10 100 ans)
                                }

                            else
                                a
                        )
                        model.answers
            }


viewAnswerInput : Answer -> Element.Element Msg
viewAnswerInput answerModel =
    Element.Input.text [ Element.Border.width 0, Element.htmlAttribute (Html.Attributes.type_ "tel") ]
        { onChange = AnswerGiven answerModel.oneIndex
        , text =
            answerModel.yourAnswer
                |> Maybe.map String.fromInt
                |> Maybe.withDefault ""
        , placeholder = Nothing
        , label = Element.Input.labelHidden ""
        }


viewDiffInput : Answer -> Element.Element Msg
viewDiffInput answerModel =
    Element.row [ Element.height fill ]
        [ Element.Input.text [ Element.Border.width 0, Element.htmlAttribute (Html.Attributes.type_ "tel") ]
            { onChange = DiffGiven answerModel.oneIndex
            , text =
                answerModel.diff
                    |> Maybe.map String.fromInt
                    |> Maybe.withDefault ""
            , placeholder = Nothing
            , label = Element.Input.labelHidden ""
            }
        , Element.Input.button
            [ Element.Background.color (Element.rgb 0 128 0), Element.htmlAttribute (Html.Attributes.type_ "tel") ]
            { onPress =
                Just (DiffGiven answerModel.oneIndex "-10")
            , label =
                text "-10"
            }
        ]


viewTable withHeader answers =
    Element.table [ Element.width (Element.fill |> minimum 400) ]
        { data = answers
        , columns =
            [ { header = Element.text ""
              , width = fillPortion 1
              , view =
                    \answer ->
                        Element.el
                            [ Element.height Element.fill
                            , Element.Border.widthEach { left = 0, right = 1, top = 0, bottom = 1 }
                            , Element.padding 10
                            ]
                            (Element.text (String.fromInt answer.oneIndex))
              }
            , { header =
                    if withHeader then
                        Element.text "Your answer 0-100"

                    else
                        Element.none
              , width = fillPortion 3
              , view =
                    \answer ->
                        Element.el [ Element.Border.widthEach { left = 0, right = 1, top = 0, bottom = 1 } ]
                            (viewAnswerInput answer)
              }
            , { header =
                    if withHeader then
                        Element.text "Diff/Points"

                    else
                        Element.none
              , width = fillPortion 3
              , view =
                    \answer ->
                        Element.el [ Element.Border.widthEach { left = 0, right = 1, top = 0, bottom = 1 } ]
                            (viewDiffInput answer)
              }
            ]
        }


viewPartSum name msg sum =
    Element.row
        [ Element.Border.width 1
        , Element.height
            fill
        , Element.width (Element.fill |> minimum 400)
        ]
        [ Element.el
            [ Element.height fill
            , Element.width (fillPortion 4)
            , Element.Border.widthEach
                { left = 0, right = 1, top = 0, bottom = 0 }
            ]
            (Element.el [ Element.alignRight, Element.padding 10 ] (Element.text name))
        , Element.el [ Element.alignRight, Element.width (fillPortion 3) ]
            (Element.Input.text [ Element.Border.width 0, Element.htmlAttribute (Html.Attributes.type_ "tel") ]
                { onChange = msg
                , text = sum
                , placeholder = Nothing
                , label = Element.Input.labelHidden ""
                }
            )
        ]


view : Model -> Html Msg
view model =
    Element.layout [ Element.padding 10, Element.width (fill |> minimum 450) ] <|
        Element.column [ Element.spacing 0, Element.width (fill |> maximum 600) ]
            [ viewTable True (model.answers |> List.take 7)
            , viewPartSum "Part sum" ChangedPartSum1 model.partSum1
            , viewTable False (model.answers |> List.drop 7 |> List.take 7)
            , viewPartSum "Part sum" ChangedPartSum2 model.partSum2
            , viewTable False (model.answers |> List.drop 14 |> List.take 7)
            , viewPartSum "Part sum" ChangedPartSum3 model.partSum3
            , viewPartSum "Total sum" ChangedTotalSum model.totalSum
            ]


main : Program () Model Msg
main =
    Browser.sandbox
        { init = initialModel
        , view = view
        , update = update
        }

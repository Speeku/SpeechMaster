//
//  VideoPlayerViewModel.swift
//  swiftuiLandingPageTrial1
//
//  Created by Kushagra Kulshrestha on 20/01/25.
//
import Foundation
class VideoPlayerViewModel: ObservableObject {
    let videoDetails: [String: VideoDetails] = [
        "steve_jobs": VideoDetails(
            title: "Steve Jobs introduces iPhone in 2007",
            videoURL: "https://youtube.com/embed/MnrJzXM7a6o",
            summary: [
                TimeStampSection(
                    title: "Opening and setting the stage",
                    timeRange: "0:00 - 0:15",
                    details: SectionDetails(
                        bodyLanguage: "Steve Jobs appears calm and confident, walking onto the stage with a relaxed demeanor. He uses a brief pause to establish his presence and connect with the audience.",
                        adaptationTip: "When beginning a speech, take a moment to pause and establish eye contact with the audience. Start with a calm and collected posture.",
                        speech: "Jobs begins with a conversational tone, making the audience feel like they are part of a momentous occasion."
                    )
                ),
                TimeStampSection(
                    title: "The introduction of the iPhone",
                    timeRange: "0:16 - 0:45",
                    details: SectionDetails(
                        bodyLanguage: "Jobs gestures enthusiastically, highlighting the unique features of the iPhone. He uses simple, yet powerful language to convey the device's capabilities.",
                        adaptationTip: "When introducing a new product or technology, use vivid gestures and metaphors to make the concept more engaging.",
                        speech: "Jobs passionately explains the iPhone's revolutionary features, emphasizing its simplicity and potential."
                    )
                ),
                TimeStampSection(
                    title: "The closing remarks",
                    timeRange: "0:45 - 1:00",
                    details: SectionDetails(
                        bodyLanguage: "Jobs delivers a final, powerful speech, emphasizing the iPhone's impact on the world.",
                        adaptationTip: "When concluding a speech, reinforce the main points and leave a lasting impression on the audience.",
                        speech: "Jobs concludes by emphasizing the iPhone's potential to change the course of history, inspiring the audience to embrace the future."
                    )
                ),
                TimeStampSection(
                    title: "The final shot",
                    timeRange: "1:00 - End",
                    details: SectionDetails(
                        bodyLanguage: "The screen fades to black, leaving the audience with a sense of awe and inspiration.",
                        adaptationTip: "Use the final shot to create a sense of closure and leave a lasting impression on the audience.",
                        speech: nil
                    )
                )
            ]
        ),
        "barack_obama": VideoDetails(
            title: "Barack Obama's Speech on Education (2004)",
            videoURL: "https://www.youtube.com/embed/2hOp408Ib5w",
            summary: [
                TimeStampSection(
                    title: "Opening Remarks",
                    timeRange: "0:00 - 0:20",
                    details: SectionDetails(
                        bodyLanguage: "Obama confidently stands at the podium, establishing a strong connection with the audience.",
                        adaptationTip: "Begin by acknowledging your audience and making them feel engaged.",
                        speech: "He starts with a powerful statement about the importance of education for everyone."
                    )
                ),
                TimeStampSection(
                    title: "The Vision for Education",
                    timeRange: "0:21 - 0:50",
                    details: SectionDetails(
                        bodyLanguage: "Obama uses his hands to emphasize key points, showcasing the importance of reform.",
                        adaptationTip: "Use hand gestures to underline the importance of the topic.",
                        speech: "He talks about the vision of providing education to all and making it accessible to every child."
                    )
                ),
                TimeStampSection(
                    title: "The Call to Action",
                    timeRange: "0:51 - 1:10",
                    details: SectionDetails(
                        bodyLanguage: "Obama intensifies his tone, encouraging the audience to take action for change.",
                        adaptationTip: "End with a strong call to action that encourages the audience to take part in the mission.",
                        speech: "Obama urges his audience to step up and make a difference in the world of education."
                    )
                ),
                TimeStampSection(
                    title: "Final Words",
                    timeRange: "1:11 - End",
                    details: SectionDetails(
                        bodyLanguage: "He stands tall, giving the audience a moment to reflect on the message.",
                        adaptationTip: "Leave the audience with a reflective message to instill a sense of importance.",
                        speech: nil
                    )
                )
            ]
        ),
        "roger_federer": VideoDetails(
            title: "Roger Federer's Dartmouth Speech (2024)",
            videoURL: "https://youtube.com/embed/_ILk8Yai3Wo",
            summary: [
                TimeStampSection(
                    title: "Introduction and Humility",
                    timeRange: "0:00 - 0:15",
                    details: SectionDetails(
                        bodyLanguage: "Federer enters the stage with a humble smile and waves to the audience.",
                        adaptationTip: "Use humility in your introduction to make the audience connect with you.",
                        speech: "Federer speaks about how grateful he is for the opportunity to be there."
                    )
                ),
                TimeStampSection(
                    title: "Career Highlights",
                    timeRange: "0:16 - 0:45",
                    details: SectionDetails(
                        bodyLanguage: "He uses gestures to highlight key moments from his career, engaging the audience.",
                        adaptationTip: "Share key moments from your journey to inspire the audience.",
                        speech: "Federer discusses some of his greatest achievements and moments in his tennis career."
                    )
                ),
                TimeStampSection(
                    title: "Life Lessons from Tennis",
                    timeRange: "0:46 - 1:05",
                    details: SectionDetails(
                        bodyLanguage: "Federer becomes more animated, making the crowd laugh with his anecdotes.",
                        adaptationTip: "Share personal stories that not only entertain but also teach valuable lessons.",
                        speech: "Federer talks about the lessons tennis has taught him about perseverance, hard work, and resilience."
                    )
                ),
                TimeStampSection(
                    title: "Closing Remarks",
                    timeRange: "1:06 - End",
                    details: SectionDetails(
                        bodyLanguage: "Federer delivers a heartfelt closing, thanking everyone for their support.",
                        adaptationTip: "End with gratitude and a reminder of the bigger picture.",
                        speech: "Federer thanks the audience for their time and support, leaving them with a sense of appreciation."
                    )
                )
            ]
        ),
        "martin_luther_king": VideoDetails(
            title: "Martin Luther King Jr.'s 'I Have a Dream' Speech (1963)",
            videoURL: "https://youtube.com/embed/vP4iY1TtS3s",
            summary: [
                TimeStampSection(
                    title: "The Vision of Equality",
                    timeRange: "0:00 - 0:20",
                    details: SectionDetails(
                        bodyLanguage: "King stands tall, delivering his opening remarks with power and clarity.",
                        adaptationTip: "Project your voice and stand with authority when stating your mission.",
                        speech: "King outlines his vision of equality and justice for all people."
                    )
                ),
                TimeStampSection(
                    title: "The Dream",
                    timeRange: "0:21 - 0:50",
                    details: SectionDetails(
                        bodyLanguage: "King’s gestures become more emphatic as he speaks about his dream for the future.",
                        adaptationTip: "As you present your vision, use strong, repeated imagery to make it memorable.",
                        speech: "King passionately expresses his dream of a world where everyone is judged by the content of their character."
                    )
                ),
                TimeStampSection(
                    title: "The Call for Action",
                    timeRange: "0:51 - 1:10",
                    details: SectionDetails(
                        bodyLanguage: "King’s voice rises, inspiring the audience to take action.",
                        adaptationTip: "Encourage the audience to believe in change and take action towards equality.",
                        speech: "King calls on the nation to act to achieve his dream of freedom and justice for all."
                    )
                ),
                TimeStampSection(
                    title: "Final Words of Hope",
                    timeRange: "1:11 - End",
                    details: SectionDetails(
                        bodyLanguage: "King ends with a sense of urgency and hope for the future.",
                        adaptationTip: "Conclude with hope and a clear vision of what the future can be.",
                        speech: nil
                    )
                )
            ]
        ),
        "simon_sinek": VideoDetails(
            title: "Simon Sinek's 'How Great Leaders Inspire Action' (2009)",
            videoURL: "https://youtube.com/embed/qp0HIF3SfI4",
            summary: [
                TimeStampSection(
                    title: "Opening Remarks",
                    timeRange: "0:00 - 0:20",
                    details: SectionDetails(
                        bodyLanguage: "Sinek starts with confidence, speaking about the power of 'Why'.",
                        adaptationTip: "Introduce your topic with a powerful, thought-provoking statement.",
                        speech: "He begins by questioning the reason behind the actions we take in leadership."
                    )
                ),
                TimeStampSection(
                    title: "The Golden Circle",
                    timeRange: "0:21 - 0:50",
                    details: SectionDetails(
                        bodyLanguage: "Sinek uses visual aids to explain the concept of the Golden Circle.",
                        adaptationTip: "Use visual aids to clarify complex ideas and make them more engaging.",
                        speech: "Sinek explains his Golden Circle theory – starting with why, then how, then what."
                    )
                ),
                TimeStampSection(
                    title: "The Power of 'Why'",
                    timeRange: "0:51 - 1:10",
                    details: SectionDetails(
                        bodyLanguage: "Sinek emphasizes the importance of clarity in communication, using strong gestures.",
                        adaptationTip: "Reinforce key points with strong gestures and a steady pace.",
                        speech: "He elaborates on how great leaders always communicate from the inside out, starting with their purpose."
                    )
                ),
                TimeStampSection(
                    title: "Final Thoughts",
                    timeRange: "1:11 - End",
                    details: SectionDetails(
                        bodyLanguage: "Sinek finishes with a passionate call to action, urging leaders to inspire others.",
                        adaptationTip: "Close with a motivational call to action that leaves the audience inspired.",
                        speech: nil
                    )
                )
            ]
        ),
        "brene_brown": VideoDetails(
            title: "Brene Brown - The Power of Vulnerability (2010)",
            videoURL: "https://youtube.com/embed/iCvmsMzlF7o",
            summary: [
                TimeStampSection(
                    title: "Opening: The Power of Vulnerability",
                    timeRange: "0:00 - 0:20",
                    details: SectionDetails(
                        bodyLanguage: "Brene Brown stands confidently, engaging the audience with eye contact.",
                        adaptationTip: "Use a confident posture and make eye contact to build trust with the audience.",
                        speech: "She introduces the idea of vulnerability and how it connects us to others."
                    )
                ),
                TimeStampSection(
                    title: "The Importance of Connection",
                    timeRange: "0:21 - 0:50",
                    details: SectionDetails(
                        bodyLanguage: "Brene uses hand gestures to emphasize the importance of connection in our lives.",
                        adaptationTip: "Use gestures to underline the significance of key ideas.",
                        speech: "She talks about the need for people to embrace their imperfections and connect with others."
                    )
                ),
                TimeStampSection(
                    title: "The Vulnerability Journey",
                    timeRange: "0:51 - 1:10",
                    details: SectionDetails(
                        bodyLanguage: "Brene shares personal anecdotes to illustrate her points.",
                        adaptationTip: "Share personal stories to make your speech more relatable and impactful.",
                        speech: "She explains how vulnerability can lead to courage, creativity, and meaningful connections."
                    )
                ),
                TimeStampSection(
                    title: "Closing: Embracing Vulnerability",
                    timeRange: "1:11 - End",
                    details: SectionDetails(
                        bodyLanguage: "Brene ends with a call to embrace vulnerability as a source of strength.",
                        adaptationTip: "Close with a call to action that challenges the audience to think differently.",
                        speech: nil
                    )
                )
            ]
        ),
        "elon_musk": VideoDetails(
            title: "Elon Musk's 'The Future of Humanity' Speech (2017)",
            videoURL: "https://youtube.com/embed/evvGzftJlG8",
            summary: [
                TimeStampSection(
                    title: "Introduction: The Quest for Innovation",
                    timeRange: "0:00 - 0:20",
                    details: SectionDetails(
                        bodyLanguage: "Musk's gestures are calm yet authoritative as he starts speaking about humanity’s future.",
                        adaptationTip: "Set the tone for your speech by establishing a vision for the future.",
                        speech: "He speaks about the importance of innovation for the progress of humanity."
                    )
                ),
                TimeStampSection(
                    title: "Space Exploration and Colonization",
                    timeRange: "0:21 - 0:50",
                    details: SectionDetails(
                        bodyLanguage: "Musk uses engaging hand gestures to illustrate his vision of space exploration.",
                        adaptationTip: "Use gestures to emphasize important topics, such as space or technology.",
                        speech: "Musk discusses the necessity of space exploration and the future of human colonies on Mars."
                    )
                ),
                TimeStampSection(
                    title: "Sustainability and Innovation",
                    timeRange: "0:51 - 1:10",
                    details: SectionDetails(
                        bodyLanguage: "Musk maintains a steady tone, underscoring the role of innovation in solving global problems.",
                        adaptationTip: "Balance enthusiasm with calmness when discussing serious, long-term goals.",
                        speech: "He elaborates on how technological advancements will lead to a sustainable future for Earth."
                    )
                ),
                TimeStampSection(
                    title: "Conclusion: Human Potential",
                    timeRange: "1:11 - End",
                    details: SectionDetails(
                        bodyLanguage: "Musk’s demeanor becomes more reflective, leaving the audience with hope and curiosity.",
                        adaptationTip: "End on a note that inspires your audience to think about the bigger picture.",
                        speech: nil
                    )
                )
            ]
        ),
        "malala_yousafzai": VideoDetails(
            title: "Malala Yousafzai's UN Youth Assembly Speech (2013)",
            videoURL: "https://youtube.com/embed/3rS6tLqP0JM",
            summary: [
                TimeStampSection(
                    title: "Opening and Acknowledging the Importance of Education",
                    timeRange: "0:00 - 0:20",
                    details: SectionDetails(
                        bodyLanguage: "Malala confidently stands at the podium, speaking with grace and conviction.",
                        adaptationTip: "Begin by acknowledging the importance of your cause and its relevance.",
                        speech: "She begins by emphasizing the importance of education and the power it holds to change the world."
                    )
                ),
                TimeStampSection(
                    title: "The Fight for Girls' Education",
                    timeRange: "0:21 - 0:50",
                    details: SectionDetails(
                        bodyLanguage: "Malala’s expression becomes more determined as she discusses her fight for girls’ education.",
                        adaptationTip: "Show determination in your body language when talking about causes close to your heart.",
                        speech: "She shares her personal journey and the challenges she faced in the fight for girls’ education."
                    )
                ),
                TimeStampSection(
                    title: "Global Call to Action",
                    timeRange: "0:51 - 1:10",
                    details: SectionDetails(
                        bodyLanguage: "Her voice grows stronger as she urges the world to take action for education.",
                        adaptationTip: "Deliver a strong, empowering call to action to encourage the audience to make a difference.",
                        speech: "Malala calls on the world to take action and ensure that every child has access to education."
                    )
                ),
                TimeStampSection(
                    title: "Final Words of Hope",
                    timeRange: "1:11 - End",
                    details: SectionDetails(
                        bodyLanguage: "Malala’s voice is full of hope as she concludes her speech.",
                        adaptationTip: "Close with words of hope and vision for the future to inspire your audience.",
                        speech: nil
                    )
                )
            ]
        ),
        "jk_rowling": VideoDetails(
            title: "J.K. Rowling's Harvard Commencement Speech (2008)",
            videoURL: "https://youtube.com/embed/wHGv6zVxgMM",
            summary: [
                TimeStampSection(
                    title: "Opening: The Importance of Failure",
                    timeRange: "0:00 - 0:20",
                    details: SectionDetails(
                        bodyLanguage: "Rowling opens with a relaxed posture, making the audience feel at ease.",
                        adaptationTip: "Start by acknowledging the real struggles people face to show vulnerability.",
                        speech: "She begins by talking about the importance of failure and how it shaped her success."
                    )
                ),
                TimeStampSection(
                    title: "The Power of Imagination",
                    timeRange: "0:21 - 0:50",
                    details: SectionDetails(
                        bodyLanguage: "Rowling’s gestures become animated as she speaks about the power of imagination.",
                        adaptationTip: "Use engaging gestures when discussing abstract concepts like imagination.",
                        speech: "She emphasizes the importance of imagination in overcoming challenges and creating change."
                    )
                ),
                TimeStampSection(
                    title: "The Value of Friendship and Empathy",
                    timeRange: "0:51 - 1:10",
                    details: SectionDetails(
                        bodyLanguage: "Rowling speaks warmly, using hand gestures to reinforce her words.",
                        adaptationTip: "Use open, empathetic gestures when discussing connection with others.",
                        speech: "Rowling talks about the value of friendship, empathy, and how these qualities help us grow."
                    )
                ),
                TimeStampSection(
                    title: "Final Words: The Future is in Your Hands",
                    timeRange: "1:11 - End",
                    details: SectionDetails(
                        bodyLanguage: "Rowling finishes with a heartfelt message of encouragement for the graduates.",
                        adaptationTip: "End your speech by empowering your audience and leaving them with hope.",
                        speech: nil
                    )
                )
            ]
        ),
        "winston_churchill": VideoDetails(
            title: "Winston Churchill's 'We Shall Fight on the Beaches' (1940)",
            videoURL: "https://youtube.com/embed/j3y4yB_oC-k",
            summary: [
                TimeStampSection(
                    title: "Opening: Rallying for the Nation",
                    timeRange: "0:00 - 0:20",
                    details: SectionDetails(
                        bodyLanguage: "Churchill delivers his opening words with a firm stance, exuding confidence and determination.",
                        adaptationTip: "Use strong, confident body language when addressing a nation in a time of crisis.",
                        speech: "He begins by rallying the British people to face the dire challenges ahead with courage."
                    )
                ),
                TimeStampSection(
                    title: "The Defiance Against Oppression",
                    timeRange: "0:21 - 0:50",
                    details: SectionDetails(
                        bodyLanguage: "Churchill’s voice rises with defiance as he speaks about resisting oppression.",
                        adaptationTip: "Let your voice and body language project defiance when talking about freedom.",
                        speech: "Churchill speaks about the strength and resolve needed to resist the forces of tyranny."
                    )
                ),
                TimeStampSection(
                    title: "Call for Unity and Perseverance",
                    timeRange: "0:51 - 1:10",
                    details: SectionDetails(
                        bodyLanguage: "Churchill’s stance becomes even more resolute as he calls for unity and perseverance.",
                        adaptationTip: "Focus on unity when discussing collective efforts, and encourage perseverance.",
                        speech: "He calls on every citizen to unite and continue fighting for freedom and victory."
                    )
                ),
                TimeStampSection(
                    title: "Final Words: Victory is Certain",
                    timeRange: "1:11 - End",
                    details: SectionDetails(
                        bodyLanguage: "Churchill’s final words are delivered with firm conviction, leaving no doubt in the listeners' minds.",
                        adaptationTip: "End with absolute confidence to leave your audience inspired and resolute.",
                        speech: nil
                    )
                )
            ]
        )
    ]
}


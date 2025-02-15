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
            title: "Steve Jobs' Stanford Commencement Speech (2005)",
            videoURL: "https://youtube.com/embed/UF8uR6Z6KLc",
            summary: [
                TimeStampSection(
                    title: "Opening Story",
                    timeRange: "0:00 - 0:20",
                    details: SectionDetails(
                        bodyLanguage: "Jobs stands casually but confidently, speaking with authenticity.",
                        adaptationTip: "Share personal stories that illustrate larger life lessons.",
                        speech: "Jobs begins with his story of dropping out of college.",
                        keywords: ["personal", "authenticity", "education"]
                    ),
                    startTime: 0,
                    endTime: 20
                ),
                TimeStampSection(
                    title: "Connecting the Dots",
                    timeRange: "0:21 - 0:50",
                    details: SectionDetails(
                        bodyLanguage: "Jobs uses thoughtful pauses and measured speech to emphasize wisdom.",
                        adaptationTip: "Use pauses effectively to let important messages sink in.",
                        speech: "He explains how seemingly unrelated life events connect in hindsight.",
                        keywords: ["wisdom", "perspective", "life lessons"]
                    ),
                    startTime: 21,
                    endTime: 50
                ),
                TimeStampSection(
                    title: "Following Your Heart",
                    timeRange: "0:51 - 1:10",
                    details: SectionDetails(
                        bodyLanguage: "Jobs leans forward, speaking with increased intensity about passion.",
                        adaptationTip: "Show conviction when discussing beliefs and values.",
                        speech: "He emphasizes the importance of following your heart and intuition.",
                        keywords: ["passion", "intuition", "purpose"]
                    ),
                    startTime: 51,
                    endTime: 70
                )
            ],
            transcript: "Full transcript of Steve Jobs' Stanford Commencement Speech...",
            viewCount: 25000000,
            rating: 4.9
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
                        speech: "He starts with a powerful statement about the importance of education for everyone.",
                        keywords: ["confidence", "engagement", "education"]
                    ),
                    startTime: 0,
                    endTime: 20
                ),
                TimeStampSection(
                    title: "The Vision for Education",
                    timeRange: "0:21 - 0:50",
                    details: SectionDetails(
                        bodyLanguage: "Obama uses his hands to emphasize key points, showcasing the importance of reform.",
                        adaptationTip: "Use hand gestures to underline the importance of the topic.",
                        speech: "He talks about the vision of providing education to all and making it accessible to every child.",
                        keywords: ["vision", "reform", "accessibility"]
                    ),
                    startTime: 21,
                    endTime: 50
                ),
                TimeStampSection(
                    title: "The Call to Action",
                    timeRange: "0:51 - 1:10",
                    details: SectionDetails(
                        bodyLanguage: "Obama intensifies his tone, encouraging the audience to take action for change.",
                        adaptationTip: "End with a strong call to action that encourages the audience to take part in the mission.",
                        speech: "Obama urges his audience to step up and make a difference in the world of education.",
                        keywords: ["call to action", "change", "motivation"]
                    ),
                    startTime: 51,
                    endTime: 70
                )
            ],
            transcript: "Full transcript of Obama's education speech...",
            viewCount: 10000000,
            rating: 4.8
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
                        speech: "Federer speaks about how grateful he is for the opportunity to be there.",
                        keywords: ["humility", "gratitude", "connection"]
                    ),
                    startTime: 0,
                    endTime: 15
                ),
                TimeStampSection(
                    title: "Career Highlights",
                    timeRange: "0:16 - 0:45",
                    details: SectionDetails(
                        bodyLanguage: "He uses gestures to highlight key moments from his career, engaging the audience.",
                        adaptationTip: "Share key moments from your journey to inspire the audience.",
                        speech: "Federer discusses some of his greatest achievements and moments in his tennis career.",
                        keywords: ["achievements", "journey", "inspiration"]
                    ),
                    startTime: 16,
                    endTime: 45
                ),
                TimeStampSection(
                    title: "Life Lessons from Tennis",
                    timeRange: "0:46 - 1:05",
                    details: SectionDetails(
                        bodyLanguage: "Federer becomes more animated, making the crowd laugh with his anecdotes.",
                        adaptationTip: "Share personal stories that not only entertain but also teach valuable lessons.",
                        speech: "Federer talks about the lessons tennis has taught him about perseverance, hard work, and resilience.",
                        keywords: ["lessons", "perseverance", "resilience"]
                    ),
                    startTime: 46,
                    endTime: 65
                )
            ],
            transcript: "Full transcript of Federer's Dartmouth speech...",
            viewCount: 5000000,
            rating: 4.7
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
                        speech: "King outlines his vision of equality and justice for all people.",
                        keywords: ["vision", "equality", "justice"]
                    ),
                    startTime: 0,
                    endTime: 20
                ),
                TimeStampSection(
                    title: "The Dream",
                    timeRange: "0:21 - 0:50",
                    details: SectionDetails(
                        bodyLanguage: "King's gestures become more emphatic as he speaks about his dream for the future.",
                        adaptationTip: "As you present your vision, use strong, repeated imagery to make it memorable.",
                        speech: "King passionately expresses his dream of a world where everyone is judged by the content of their character.",
                        keywords: ["dream", "future", "character"]
                    ),
                    startTime: 21,
                    endTime: 50
                ),
                TimeStampSection(
                    title: "The Call for Action",
                    timeRange: "0:51 - 1:10",
                    details: SectionDetails(
                        bodyLanguage: "King's voice rises, inspiring the audience to take action.",
                        adaptationTip: "Encourage the audience to believe in change and take action towards equality.",
                        speech: "King calls on the nation to act to achieve his dream of freedom and justice for all.",
                        keywords: ["inspiration", "action", "freedom"]
                    ),
                    startTime: 51,
                    endTime: 70
                )
            ],
            transcript: "Full transcript of MLK's I Have a Dream speech...",
            viewCount: 20000000,
            rating: 5.0
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
                        speech: "He begins by questioning the reason behind the actions we take in leadership.",
                        keywords: ["why", "purpose", "leadership"]
                    ),
                    startTime: 0,
                    endTime: 20
                ),
                TimeStampSection(
                    title: "The Golden Circle",
                    timeRange: "0:21 - 0:50",
                    details: SectionDetails(
                        bodyLanguage: "Sinek uses visual aids to explain the concept of the Golden Circle.",
                        adaptationTip: "Use visual aids to clarify complex ideas and make them more engaging.",
                        speech: "Sinek explains his Golden Circle theory – starting with why, then how, then what.",
                        keywords: ["golden circle", "concept", "theory"]
                    ),
                    startTime: 21,
                    endTime: 50
                ),
                TimeStampSection(
                    title: "The Power of 'Why'",
                    timeRange: "0:51 - 1:10",
                    details: SectionDetails(
                        bodyLanguage: "Sinek emphasizes the importance of clarity in communication, using strong gestures.",
                        adaptationTip: "Reinforce key points with strong gestures and a steady pace.",
                        speech: "He elaborates on how great leaders always communicate from the inside out, starting with their purpose.",
                        keywords: ["communication", "purpose", "leadership"]
                    ),
                    startTime: 51,
                    endTime: 70
                )
            ],
            transcript: "Full transcript of Simon Sinek's TED talk...",
            viewCount: 8000000,
            rating: 4.8
        ),
        "brene_brown": VideoDetails(
            title: "Brené Brown's 'The Power of Vulnerability' (2010)",
            videoURL: "https://youtube.com/embed/iCvmsMzlF7o",
            summary: [
                TimeStampSection(
                    title: "Introduction to Vulnerability",
                    timeRange: "0:00 - 0:20",
                    details: SectionDetails(
                        bodyLanguage: "Brown begins with a relaxed, approachable stance, using humor to connect.",
                        adaptationTip: "Use personal stories and humor to make complex topics more accessible.",
                        speech: "Brown introduces her research on vulnerability and human connection.",
                        keywords: ["vulnerability", "connection", "research"]
                    ),
                    startTime: 0,
                    endTime: 20
                ),
                TimeStampSection(
                    title: "The Research Findings",
                    timeRange: "0:21 - 0:50",
                    details: SectionDetails(
                        bodyLanguage: "Brown uses hand gestures to emphasize key points, maintaining eye contact.",
                        adaptationTip: "Use data and research to support your message while keeping it relatable.",
                        speech: "She shares insights from her research on shame and vulnerability.",
                        keywords: ["research", "shame", "insights"]
                    ),
                    startTime: 21,
                    endTime: 50
                ),
                TimeStampSection(
                    title: "Embracing Vulnerability",
                    timeRange: "0:51 - 1:10",
                    details: SectionDetails(
                        bodyLanguage: "Brown's expressions become more passionate as she discusses transformation.",
                        adaptationTip: "Show genuine emotion when discussing transformative ideas.",
                        speech: "She explains how embracing vulnerability leads to stronger connections.",
                        keywords: ["transformation", "connection", "strength"]
                    ),
                    startTime: 51,
                    endTime: 70
                )
            ],
            transcript: "Full transcript of Brené Brown's TED talk...",
            viewCount: 15000000,
            rating: 4.9
        ),
        "elon_musk": VideoDetails(
            title: "Elon Musk's SpaceX Vision (2017)",
            videoURL: "https://youtube.com/embed/H7Uyfqi_TE8",
            summary: [
                TimeStampSection(
                    title: "The Vision for Mars",
                    timeRange: "0:00 - 0:20",
                    details: SectionDetails(
                        bodyLanguage: "Musk speaks with calculated enthusiasm, using precise gestures.",
                        adaptationTip: "Balance technical detail with engaging delivery when discussing complex topics.",
                        speech: "Musk outlines his vision for making humanity a multi-planetary species.",
                        keywords: ["vision", "space", "innovation"]
                    ),
                    startTime: 0,
                    endTime: 20
                ),
                TimeStampSection(
                    title: "Technical Challenges",
                    timeRange: "0:21 - 0:50",
                    details: SectionDetails(
                        bodyLanguage: "Musk uses visual aids and gestures to explain technical concepts.",
                        adaptationTip: "Break down complex ideas into digestible parts using visual aids.",
                        speech: "He explains the technical challenges of Mars colonization.",
                        keywords: ["technical", "challenges", "solutions"]
                    ),
                    startTime: 21,
                    endTime: 50
                ),
                TimeStampSection(
                    title: "The Path Forward",
                    timeRange: "0:51 - 1:10",
                    details: SectionDetails(
                        bodyLanguage: "Musk's tone becomes more determined when discussing timeline and goals.",
                        adaptationTip: "Show conviction when discussing ambitious goals and timelines.",
                        speech: "He outlines the roadmap for achieving Mars colonization.",
                        keywords: ["goals", "timeline", "future"]
                    ),
                    startTime: 51,
                    endTime: 70
                )
            ],
            transcript: "Full transcript of Elon Musk's SpaceX Vision presentation...",
            viewCount: 12000000,
            rating: 4.7
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
                        bodyLanguage: "Malala's expression becomes more determined as she discusses her fight for girls' education.",
                        adaptationTip: "Show determination in your body language when talking about causes close to your heart.",
                        speech: "She shares her personal journey and the challenges she faced in the fight for girls' education."
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
                        bodyLanguage: "Malala's voice is full of hope as she concludes her speech.",
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
                        bodyLanguage: "Rowling's gestures become animated as she speaks about the power of imagination.",
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
                        bodyLanguage: "Churchill's voice rises with defiance as he speaks about resisting oppression.",
                        adaptationTip: "Let your voice and body language project defiance when talking about freedom.",
                        speech: "Churchill speaks about the strength and resolve needed to resist the forces of tyranny."
                    )
                ),
                TimeStampSection(
                    title: "Call for Unity and Perseverance",
                    timeRange: "0:51 - 1:10",
                    details: SectionDetails(
                        bodyLanguage: "Churchill's stance becomes even more resolute as he calls for unity and perseverance.",
                        adaptationTip: "Focus on unity when discussing collective efforts, and encourage perseverance.",
                        speech: "He calls on every citizen to unite and continue fighting for freedom and victory."
                    )
                ),
                TimeStampSection(
                    title: "Final Words: Victory is Certain",
                    timeRange: "1:11 - End",
                    details: SectionDetails(
                        bodyLanguage: "Churchill's final words are delivered with firm conviction, leaving no doubt in the listeners' minds.",
                        adaptationTip: "End with absolute confidence to leave your audience inspired and resolute.",
                        speech: nil
                    )
                )
            ]
        )
    ]
}


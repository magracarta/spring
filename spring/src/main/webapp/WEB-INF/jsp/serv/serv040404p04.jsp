<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 서비스 > 고객관리 > 전화업무 통합관리 > Happy Call > 고객수신모바일
-- 작성자 : 최보성
-- 최초 작성일 : 2020-04-07 19:54:29
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>

	<meta name="viewport" content="width=device-width, initial-scale=1, user-scalable=no">
	<title>YK건기 ERP</title>
	<link rel="stylesheet" type="text/css" href="/static/css/style-m.css" />
	<link href="https://fonts.googleapis.com/css?family=Nanum+Gothic&display=swap" rel="stylesheet">
	<script type="text/javascript" src="/static/js/jquery.min.js"></script>
	<script type="text/javascript" src="/static/js/jquery.mfactory-2.2.js"></script>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>

	<script type="text/javascript">
		$(document).ready(function () {
	        if('${survey_show}'=="Y") {
	        	$(".survey-start").css("display","");
	        	$(".survey-end").css("display","none");
	        } else {
	        	$(".survey-start").css("display","none");
	        	$(".survey-end").css("display","");
	        }

	        if ('${inputParam.preview_yn}' != 'Y' && '${inputParam.send_yn}' == 'N') {
	        	fnSetUrl();
	        }

	    });

		function fnSendSms() {
			var custInfo = ${custInfo};

				var msg = "YK건기를 이용해 주셔서 감사합니다.\\n당사는 고객님께보다 나은 서비스를 위해 간단한 설문을 진행하고 있습니다.\\n\\n";
				msg += $M.getValue("happycall_url");
				var param = {
					"name" : custInfo.cust_name,
					"hp_no" : custInfo.hp_no,
					"send_type" : "happyCall",
					"msg" : msg,
					"job_report_no" : $M.getValue("job_report_no"),
					"survey_url" : $M.getValue("happycall_url")
				}

				openSendSmsPanel($M.toGetParam(param));

		}

		function fnSetUrl() {
			var jobReportNo = $M.getValue("job_report_no");

			var param = {
				"shorcut_url" : "/serv/serv040404p04",
				"job_report_no" : jobReportNo
			};

			$M.goNextPageAjax("/shortenUrl/makeShortenUrl", $M.toGetParam(param), {method : "GET"},
					function(result) {
						$M.setValue("happycall_url", result.url);
					}
			);
		}

		function goSave() {
			var questionTypeList = $("input[id^='ques_type']");
			var questionSeq = 1;

			var custAnswerList = "";
			var seqList = "";
			var quesMfList = "";

			for(var i = 0 ; i < questionTypeList.length ; i++) {
				questionSeq = questionTypeList[i].id.replace("ques_type","");

				quesMfList += $("#"+questionTypeList[i].id).val()+"#";
				seqList += questionSeq+"#";

				if( $("#"+questionTypeList[i].id).val() == "M"){ //객관식
					var answerMList = $("input[name^='answer"+questionSeq+"']");

					if($("#answer_require"+questionSeq).val() == "Y") { //필수여부
						if($("input[name="+answerMList[0].name+"]:checked").val()==undefined) {
							alert("질의 "+questionSeq+ "의 정답이 없습니다.");
							return;
						} else {
							custAnswerList += $("input[name="+answerMList[0].name+"]:checked").val()+"#";
						}
					} else {
						if($("input[name="+answerMList[0].name+"]:checked").val()==undefined) {
							custAnswerList += "null#"
						} else {
							custAnswerList += $("input[name="+answerMList[0].name+"]:checked").val()+"#";
						}
					}
				}else {	//주관식
					if($("#answer_require"+questionSeq).val() == "Y") { //필수여부
						if($.trim($("textarea[name='answer"+questionSeq+"']").val()) == "" && $("#least_char_cnt"+questionSeq).val() != 0) {
							alert("질의 "+questionSeq+ "의 정답이 없습니다.");
							return;
						} else {
							if($.trim($("textarea[name='answer"+questionSeq+"']").val()).length < $("#least_char_cnt"+questionSeq).val()){
								alert("질의"+questionSeq+" 의 최소 입력 글자수는 " + $("#least_char_cnt"+questionSeq).val() + "자리 입니다.");
								return;
							}
							custAnswerList += $.trim($("textarea[name='answer"+questionSeq+"']").val())+"#";
						}
					} else {
						custAnswerList += $.trim($("textarea[name='answer"+questionSeq+"']").val())+"#";
					}
				}
			}

			if(custAnswerList.length > 0) {
				custAnswerList = custAnswerList.substring(0, custAnswerList.length -1);
			}

			var param = {
					"custAnswerList" : custAnswerList
					, "seqList" : seqList
					, "quesMfList" : quesMfList
					, "survey_seq" : $("#survey_seq").val()
					, "job_report_no" : $("#job_report_no").val()
			};

			$M.goNextPageAjaxSave("/serv/serv040404p04/save", $M.toGetParam(param), {method : 'POST'},
				function(result) {
					if(result.success) {
						$(".survey-start").css("display","none");
			        	$(".survey-end").css("display","");
					}
				}
			);
		}

		function fnClose() {
	    	window.open('about:blank','_self').self.close();
	    }

		// 닫기
		function goClose() {
			window.close();
		}
	</script>

</head>
<body>
<form id="main_form" name="main_form">
<input type="hidden" id="happycall_url" name="happycall_url">
<!-- 이 페이지는 개별 모바일 페이지로 css와 이미지를 따로 사용합니다.-->
<!-- style-m.css / icons-m.png -->

<!-- 상단타이틀영역 -->
	<div class="main-title-m">
		<h1>
			<span class="text-primary">Y</span><span class="text-secondary">K</span>건기 고객만족도 설문조사
		</h1>
		<button type="button" onclick="fnClose();">
			<i class="icon-btn-close"></i>
		</button>
	</div>
<!-- /상단타이틀영역 -->
<!-- contents 전체 영역 -->
	<div class="survey-content survey-start">
		<input type="hidden" id="survey_seq" name="survey_seq" value="${survey_seq}">
		<input type="hidden" id="job_report_no" name="job_report_no" value="${job_report_no}">
		<div class="survey-list">
		<c:forEach var="ques_list" items="${ques_list }">
			<c:if test = "${ques_list.ques_type_mf== 'M' }">
				<!-- 만족도 리스트 -->
				<input type="hidden" id="ques_type${ques_list.seq_no}" value="${ques_list.ques_type_mf}">
				<input type="hidden" id="answer_require${ques_list.seq_no}" value="${ques_list.required_yn}">
				<div class="survey" id="ques${ques_list.seq_no}">
					<h4>질의 ${ques_list.seq_no}. ${ques_list.ques_title }</h4>
					<ul>
						<c:forEach var="item_list" items="${item_list }">
							<c:if test = "${ques_list.seq_no== item_list.ques_seq_no }">
								<li>
									<input type="radio" name="answer${ques_list.seq_no}" id="answer${ques_list.seq_no}${item_list.seq_no }" value="${item_list.seq_no }">
									<label for="answer${ques_list.seq_no}${item_list.seq_no }">${item_list.seq_no }. ${item_list.item_title }</label>
								</li>
							</c:if>
						</c:forEach>
					</ul>
					</div>
				<!-- /만족도 리스트 -->
			</c:if>
			<c:if test = "${ques_list.ques_type_mf== 'F' }">
				<!-- 서술형 -->
				<input type="hidden" id="ques_type${ques_list.seq_no}" value="${ques_list.ques_type_mf}">
				<input type="hidden" id="answer_require${ques_list.seq_no}" value="${ques_list.required_yn}">
				<input type="hidden" id="least_char_cnt${ques_list.seq_no}" value="${ques_list.least_char_cnt}">
				<div class="description" id="ques${ques_list.seq_no}">
					<h4>질의 ${ques_list.seq_no}. ${ques_list.ques_title }</h4>
					<textarea style="height: 150px;" name="answer${ques_list.seq_no}" id="answer${ques_list.seq_no}"></textarea>
				</div>
				<!-- /서술형 -->
			</c:if>
		</c:forEach>
		</div>
<!-- 하단 버튼 -->
		<div class="footer-btn-group">
			<div class="btn-group">
				<c:if test="${inputParam.preview_yn ne 'Y'}">
					<c:choose>
						<c:when test="${inputParam.send_yn eq 'N'}">
							<button type="button" onclick="fnSendSms();" class="btn btn-block btn-primary">해피콜 발송</button>
						</c:when>
						<c:otherwise>
							<button type="button" onclick="goSave();" class="btn btn-block btn-primary">확인</button>
						</c:otherwise>
					</c:choose>
				</c:if>

				<c:if test="${inputParam.preview_yn eq 'Y'}">
					<button type="button" onclick="goClose();" class="btn btn-block btn-primary">닫기</button>
				</c:if>
			</div>
		</div>
	</div>
<!-- /하단 버튼 -->
	<div class="survey-content survey-end" style="display:none;">
		<div class="survey-wrap">
			<div class="yk-logo"></div>
			<div class="survey-txt">
				<div class="paragraph">설문에 응해 주셔서 감사합니다.</div>
				<div class="paragraph">
					응답하신 내용을 참고하여 고객만족을 넘어<br>
					고객감동을 실현할 수 있도록<br>
					최선을 다하겠습니다.
				</div>
				<div class="paragraph">감사합니다.</div>
			</div>
		</div>
<!-- 하단 버튼 -->
<%--		<div class="footer-btn-group">--%>
<%--			<div class="btn-group">--%>
<%--				<button type="button" onclick="fnClose();" class="btn btn-block btn-primary">확인</button>--%>
<%--			</div>--%>
<%--		</div>--%>
	</div>
<!-- /contents 전체 영역 -->
</form>
</body>
</html>

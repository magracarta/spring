<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 서비스 > 고객관리 > 전화업무 통합관리 > Happy Call > 설문관리
-- 작성자 : 최보성
-- 최초 작성일 : 2020-04-07 19:54:29
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
	<script type="text/javascript">
	$(document).ready(function () {
    });

	// 미리보기
	function fnPreview() {
		var params = {
			"survey_seq" : $M.getValue("asis_seq"),
			"preview_yn" : "Y"
		};

		var popupOption = "scrollbars=yes, resizable-1, mebubar=no, toolbar=no, location=no, directories=no, status=no, fullscreen=no, width=1400, height=650, left=0, top=0";
		$M.goNextPage('/serv/serv040404p04', $M.toGetParam(params), {popupStatus : popupOption});
	}

	function fnTypeMf(a) {
		var name = a.name;
		var nameSeq = name.replace("ques_type_mf","");
		var rowspan = $("#questionRowSpan"+nameSeq).val();
		
		if(a.value=="M") {
			$(".ques_type_m"+nameSeq).css("display","");
			$(".ques_type_f"+nameSeq).css("display","none");
			$("#question"+nameSeq).attr("rowspan",rowspan);
		}else {
			$(".ques_type_m"+nameSeq).css("display","none");
			$(".ques_type_f"+nameSeq).css("display","");
			$("#question"+nameSeq).attr("rowspan","2");
		}
	}
	
	function fnDeleteAnswer(num) {
		var questionNum = num.split("_");
		var countAnswerLength = $("tr[name^='answer"+questionNum[0]+"']").length;
		
		if(countAnswerLength == 1) {
			alert("예시는 1개 이상입니다.");
			return;
		}
		
		if(questionNum[1] == "1") {
			alert("예시1번은 삭제가 불가능합니다.");
			return;
		}
		
		$("#questionRowSpan"+questionNum[0]).val(parseInt($("#questionRowSpan"+questionNum[0]).val())-1);
		//$("#question"+questionNum[0]).attr("rowspan",parseInt($("#questionRowSpan"+questionNum[0]).val()));
		$("#answer"+num).remove();
	}
	
	
	function fnAddAnswer(num) {
		
		var countAnswerLength = $("tr[name^='answer"+num+"']").length;
		var countAnswerList = $("tr[name^='answer"+num+"']");
		var nextId = countAnswerList[countAnswerLength-1].id.split("_");
		
		var text = "";
		text += "<tr class='ques_type_m"+num+"' id='answer"+num+"_"+(parseInt(nextId[1])+1)+"' name='answer"+num+"_"+(parseInt(nextId[1])+1)+"'>";
		text += "    <td class='text-right td-gray'>예시"+(parseInt(nextId[1])+1)+"</td>";
		text += "    <td>";
		text += "        <div class='form-row inline-pd'>";
		text += "            <div class='col' style='width: calc(100% - 70px);'>";
		text += "            <input type='text' id='ans_item"+num+"_"+(parseInt(nextId[1])+1)+"' name='ans_item"+num+"_"+(parseInt(nextId[1])+1)+"' class='form-control' />";
		text += "        </div>";
		text += "        <div class='col width70px'>";
		text += "            <button type='button' onclick='fnDeleteAnswer(\""+num+"_"+(parseInt(nextId[1])+1)+"\")' class='btn btn-primary-gra' style='width: 100%;'>삭제</button>";
		text += "            </div>";
		text += "        </div>";
		text += "    </td>";
		text += "</tr>";
		
		var rowspan = $("#question"+num).attr("rowspan");

		rowspan = parseInt(rowspan) + 1;
		$("#question"+num).attr("rowspan",rowspan);
		$("#questionRowSpan"+num).val(rowspan);
		$("#"+countAnswerList[countAnswerLength-1].id).after(text);
	}
	
	function fnDeleteQuestion(num) {
		var countAnswerList = $("tbody[id^='questionBody']");
		if(countAnswerList.length == 1) {
			alert("문항은 1개 이상입니다.");
			return;	
		}
		$("#questionBody"+num).remove();
	}
	
	function fnAddQuestion() {
		var countAnswerList = $("tbody[id^='questionBody']");
		
		if(countAnswerList.length == 0) {
			answerSeq = 0;
		} else {
			answerSeq = parseInt((countAnswerList[countAnswerList.length-1].id).replace("questionBody",""));
		}
		
		var text = "";
		text += "<tbody id='questionBody"+(answerSeq+1)+"'>                                                                                                                                                   ";
		text += "	<input type='hidden' id='questionRowSpan"+(answerSeq+1)+"' value='5'>                                                                                                                     ";
		text += "																																											  ";
		text += "		<th rowspan='5' class='text-right' id='question"+(answerSeq+1)+"'>문항"+(answerSeq+1)+"</th>                                                                                                          ";
		text += "		<td class='text-right td-gray'>설정</td>                                                                                                                              ";
		text += "		<td>                                                                                                                                                                  ";
		text += "			<div class='form-row inline-pd widthfix'>                                                                                                                         ";
		text += "				<div class='col width145px'>                                                                                                                                  ";
		text += "					<div class='form-check form-check-inline'>                                                                                                                ";
		text += "						<input class='form-check-input' type='radio' name='ques_type_mf"+(answerSeq+1)+"' value='M' onchange='fnTypeMf(this)' checked />                                      ";
		text += "						<label class='form-check-label'>객관식</label>                                                                                                        ";
		text += "					</div>                                                                                                                                                    ";
		text += "					<div class='form-check form-check-inline' >                                                                                                               ";
		text += "						<input class='form-check-input' type='radio' name='ques_type_mf"+(answerSeq+1)+"' onchange='fnTypeMf(this)' value='F'/>                                               ";
		text += "						<label class='form-check-label'>주관식</label>                                                                                                        ";
		text += "					</div>                                                                                                                                                    ";
		text += "				</div>                                                                                                                                                        ";
		text += "				<div class='col width160px ques_type_m"+(answerSeq+1)+"'>                                                                                                                      ";
		text += "					<div class='form-check form-check-inline pl10'>                                                                                                           ";
		text += "						<input class='form-check-input' id='required_yn"+(answerSeq+1)+"' name='required_yn"+(answerSeq+1)+"' type='checkbox' checked />                                                                                            ";
		text += "						<label class='form-check-label'>필수여부</label>                                                                                                      ";
		text += "					</div>                                                                                                                                                    ";
		text += "				</div>                                                                                                                                                        ";
		text += "				<div class='col width160px ques_type_f"+(answerSeq+1)+"' style='display:none'>                                                                                                 ";
		text += "					<input type='text' id='ans_text_length"+(answerSeq+1)+"' name='ans_text_length"+(answerSeq+1)+"' class='form-control' placeholder='최소입력글자수 : 10자리' />                                                                          ";
		text += "				</div>                                                                                                                                                        ";
		text += "				<div class='col text-right' style='width: calc(100% - 305px);'>                                                                                               ";
		text += "					<button type='button' onclick='fnDeleteQuestion(\""+(answerSeq+1)+"\")' class='btn btn-primary-gra' style='width: 95px;'>문항삭제</button>                                  ";
		text += "				</div>                                                                                                                                                    ";
		text += "				</div>                                                                                                                                                        ";
		text += "			</td>                                                                                                                                                             ";
		text += "		</tr>                                                                                                                                                                 ";
		text += "		<tr>                                                                                                                                                                  ";
		text += "			<td class='text-right td-gray'>질문</td>                                                                                                                          ";
		text += "			<td class='ques_type_f"+(answerSeq+1)+"' style='display:none'>                                                                                                                     ";
		text += "				<input type='text' id='item_title_f"+(answerSeq+1)+"' name='item_title_f"+(answerSeq+1)+"' class='form-control' maxlength='90'/>                                                                                                                    ";
		text += "			</td>                                                                                                                                                             ";
		text += "			<td class='ques_type_m"+(answerSeq+1)+"'>                                                                                                                                          ";
		text += "				<div class='form-row inline-pd'>                                                                                                                              ";
		text += "					<div class='col' style='width: calc(100% - 100px);'>                                                                                                      ";
		text += "						<input type='text' id='item_title_m"+(answerSeq+1)+"' name='item_title_m"+(answerSeq+1)+"' class='form-control' maxlength='90'/>                                                                                                                ";
		text += "					</div>                                                                                                                                                        ";
		text += "					<div class='col width100px'>                                                                                                                                  ";
		text += "						<button type='button' class='btn btn-primary-gra' onclick='fnAddAnswer(\""+(answerSeq+1)+"\");' style='width: 100%;'><i class='material-iconsadd'></i>예시추가</button>     ";
		text += "					</div>                                                                                                                                                    ";
		text += "				</div>                                                                                                                                                        ";
		text += "			</td>                                                                                                                                                             ";
		text += "		</tr>                                                                                                                                                                 ";
		text += "		<tr class='ques_type_m"+(answerSeq+1)+"' id='answer"+(answerSeq+1)+"_1' name='answer"+(answerSeq+1)+"_1'>                                                                                                              ";
		text += "			<td class='text-right td-gray'>예시1</td>                                                                                                                         ";
		text += "			<td>                                                                                                                                                              ";
		text += "				<div class='form-row inline-pd'>                                                                                                                              ";
		text += "					<div class='col' style='width: calc(100% - 70px);'>                                                                                                       ";
		text += "						<input type='text' id='ans_item"+(answerSeq+1)+"_1' name='ans_item"+(answerSeq+1)+"_1' class='form-control' />                                                                                                                ";
		text += "					</div>                                                                                                                                                        ";
		text += "					<div class='col width70px'>                                                                                                                                   ";
		text += "						<button type='button' class='btn btn-primary-gra' onclick='fnDeleteAnswer(\""+(answerSeq+1)+"_1\");' style='width: 100%;'>삭제</button>                                     ";
		text += "					</div>                                                                                                                                                    ";
		text += "				</div>                                                                                                                                                        ";
		text += "			</td>                                                                                                                                                             ";
		text += "		</tr>                                                                                                                                                                 ";
		text += "		<tr class='ques_type_m"+(answerSeq+1)+"' id='answer"+(answerSeq+1)+"_2' name='answer"+(answerSeq+1)+"_2'>                                                                                                              ";
		text += "			<td class='text-right td-gray'>예시2</td>                                                                                                                         ";
		text += "			<td>                                                                                                                                                              ";
		text += "				<div class='form-row inline-pd'>                                                                                                                              ";
		text += "					<div class='col' style='width: calc(100% - 70px);'>                                                                                                       ";
		text += "						<input type='text' id='ans_item"+(answerSeq+1)+"_2' name='ans_item"+(answerSeq+1)+"_2' class='form-control' />                                                                                                                ";
		text += "					</div>                                                                                                                                                        ";
		text += "					<div class='col width70px'>                                                                                                                                   ";
		text += "						<button type='button' class='btn btn-primary-gra' onclick='fnDeleteAnswer(\""+(answerSeq+1)+"_2\")' style='width: 100%;'>삭제</button>                                      ";
		text += "					</div>                                                                                                                                                    ";
		text += "				</div>                                                                                                                                                        ";
		text += "			</td>                                                                                                                                                             ";
		text += "		</tr>                                                                                                                                                                 ";
		text += "		<tr class='ques_type_m"+(answerSeq+1)+"' id='answer"+(answerSeq+1)+"_3' name='answer"+(answerSeq+1)+"_3'>                                                                                                              ";
		text += "			<td class='text-right td-gray'>예시3</td>                                                                                                                         ";
		text += "			<td>                                                                                                                                                              ";
		text += "				<div class='form-row inline-pd'>                                                                                                                              ";
		text += "					<div class='col' style='width: calc(100% - 70px);'>                                                                                                       ";
		text += "					<input type='text' id='ans_item"+(answerSeq+1)+"_3' name='ans_item"+(answerSeq+1)+"_3' class='form-control' />                                                                                                                ";
		text += "				</div>                                                                                                                                                        ";
		text += "				<div class='col width70px'>                                                                                                                                   ";
		text += "					<button type='button' class='btn btn-primary-gra' onclick='fnDeleteAnswer(\""+(answerSeq+1)+"_3\")' style='width: 100%;'>삭제</button>                                      ";
		text += "					</div>                                                                                                                                                    ";
		text += "				</div>                                                                                                                                                        ";
		text += "			</td>                                                                                                                                                             ";
		text += "		</tr>                                                                                                                                                                 ";
		text += "</tbody>                                                                                                                                                                     ";
		
		if(countAnswerList.length == 0) {
			$(".test").append(text);
		} else {
			$("#questionBody"+answerSeq).after(text);
		}
	}
	
	// 닫기
    function fnClose() {
    	window.close();
    }

	function goSetting() {
		var questionList = $("tbody[id^='questionBody']");
		var questionSeq = 1;
		var question = "";
		var questionType = "";
		var answer = "";
		var answerRequire = "";
		var ques_title = $("#ques_title").val();

		if (ques_title == "") {
			alert("설문 제목은 필수 입력입니다.");
			return;
		}

		for (var i = 0; i < questionList.length; i++) {
			questionSeq = questionList[i].id.replace("questionBody", "");
			if ($("input[name=ques_type_mf" + questionSeq + "]:checked").val() == "M") { //객관식
				if ($("#item_title_m" + questionSeq).val() == "") {
					alert("질문은 필수 입력입니다.");
					return;
				} else {
					question += $("#item_title_m" + questionSeq).val() + "#"; //질문 리스트
					questionType += "M#"; //질문타입 리스트
					var answerList = $("input[name^='ans_item" + questionSeq + "']");
					var cnt = 0;
					for (var j = 0; j < answerList.length; j++) {
						if ($("#" + answerList[j].id).val() != "") { //정답 리스트
							cnt++;
							answer += $("#" + answerList[j].id).val() + "^";
						}
					}

					if (cnt == 0) { //정답이 없을 경우
						alert("예시에 등록된 값이 없습니다.");
						return;
					}

					answer += "#";
					if ($("#required_yn" + questionSeq).is(":checked")) { //필수여부 리스트
						answerRequire += "Y#";
					} else {
						answerRequire += "N#";
					}
				}
			} else { // 주관식
				if ($("#item_title_f" + questionSeq).val() == "") {
					alert("질문은 필수 입력입니다.");
					return;
				} else {
					question += $("#item_title_f" + questionSeq).val() + "#"; //질문 리스트
					questionType += "F#"; //질문타입 리스트
					answer += "-#";
					if ($("#ans_text_length" + questionSeq).val() == "") {
						answerRequire += "10#"; //default 입력 글자수 10자 (추후 변경)
					} else {
						answerRequire += $("#ans_text_length" + questionSeq).val() + "#"; //최소입력 글자수
					}
				}
			}
		}

		var asis_seq = "0";
		var type = "I";
		if (ques_title == $("#asis_title").val()) {
			asis_seq = $("#asis_seq").val();
			type = "U";
		}

		var msg = "작성된 내용으로 문자가 발송됩니다. 설정하시겠습니까?";

		var param = {
			"question": question,
			"questionType": questionType,
			"answer": answer,
			"answerRequire": answerRequire,
			"ques_title": ques_title,
			"type": type,
			"survey_seq": asis_seq
		};

		$M.goNextPageAjaxMsg(msg, this_page + "/save", $M.toGetParam(param), {method: 'POST'},
				function (result) {
					if (result.success) {
						$M.setValue("survey_seq", result.survey_seq);
						location.reload();
					}
				}
		);
	}

	</script>
</head>
<body class="bg-white">
<form id="main_form" name="main_form">
	<!-- 팝업 -->
	<div class="popup-wrap width-100per">
	    <!-- 타이틀영역 -->
		<div class="main-title">
			<jsp:include page="/WEB-INF/jsp/common/menuNavi.jsp"/>
		</div>
	    <!-- /타이틀영역 -->
		<div class="content-wrap">
	        <div class="form-row inline-pd widthfix">
	            <div class="col" style="width: calc(100% - 106px);">
	                <input type="text" id="ques_title" name="ques_title" value="${surveyMap.survey_title }" maxlength="90" class="form-control" />
	                <input type="hidden" id="asis_title" name="asis_title" value="${surveyMap.survey_title }" class="form-control" />
	                <input type="hidden" id="asis_seq" name="asis_seq" value="${surveyMap.survey_seq }" class="form-control" />
	            </div>
	            <div class="col width106px">
	                <button type="button" onclick="fnAddQuestion()" class="btn btn-important" style="width: 100%;"><i class="material-iconsadd"></i>문항추가</button>
	            </div>
	        </div>
	        <div>
	            <table class="table-border mt5 test">
	                <colgroup>
	                    <col width="80px" />
	                    <col width="80px" />
	                    <col width="" />
	                </colgroup>
	                <c:forEach var="surveyQuesList" items="${surveyQuesList }" varStatus="status">
						<tbody id="questionBody${status.count}">
		                	<input type="hidden" id="questionRowSpan${surveyQuesList.seq_no}" value="5">
		                	<c:if test="${surveyQuesList.ques_type_mf eq 'M'}">
		                		<th rowspan="20" class="text-right" id="question${surveyQuesList.seq_no}">문항${surveyQuesList.seq_no} </th>
		                	</c:if>
		                	<c:if test="${surveyQuesList.ques_type_mf eq 'F'}">
		                		<th rowspan="2" class="text-right" id="question${surveyQuesList.seq_no}">문항${surveyQuesList.seq_no} </th>
		                	</c:if>
							<td class="text-right td-gray">설정</td>
							<td>
							    <div class="form-row inline-pd widthfix">
							        <div class="col width145px">
							            <div class="form-check form-check-inline">
							                <input class="form-check-input" type="radio" name="ques_type_mf${surveyQuesList.seq_no}" value="M" onchange="fnTypeMf(this)" <c:if test="${surveyQuesList.ques_type_mf eq 'M'}">checked="checked"</c:if> />
							                <label class="form-check-label">객관식</label>
							            </div>
							            <div class="form-check form-check-inline" >
							                <input class="form-check-input" type="radio" name="ques_type_mf${surveyQuesList.seq_no}" onchange="fnTypeMf(this)" value="F" <c:if test="${surveyQuesList.ques_type_mf eq 'F'}">checked="checked"</c:if>/>
							                <label class="form-check-label">주관식</label>
							            </div>
							        </div>
							      
							        <div class="col width160px ques_type_m${surveyQuesList.seq_no}" <c:if test="${surveyQuesList.ques_type_mf eq 'F'}">style="display:none;"</c:if> >
							            <div class="form-check form-check-inline pl10">
							                <input class="form-check-input" id="required_yn${surveyQuesList.seq_no}" name="required_yn${surveyQuesList.seq_no}" type="checkbox" ${surveyQuesList.required_yn == "Y" ? "CHECKED" : ""} />
							                <label class="form-check-label">필수여부</label>
							               
							            </div>
							        </div>
							        
							        <div class="col width160px ques_type_f${surveyQuesList.seq_no}" <c:if test="${surveyQuesList.ques_type_mf eq 'M'}">style="display:none;"</c:if>>
						                <input type="text" id="ans_text_length${surveyQuesList.seq_no}" name="ans_text_length${surveyQuesList.seq_no}" class="form-control" placeholder="최소입력글자수 : 10자리" <c:if test="${surveyQuesList.ques_type_mf eq 'F'}"> value="${surveyQuesList.least_char_cnt }"</c:if> />
						            </div>
						            
							        <div class="col text-right" style="width: calc(100% - 305px);">
							            <button type="button" onclick="fnDeleteQuestion('${surveyQuesList.seq_no}')" class="btn btn-primary-gra" style="width: 95px;">문항삭제</button>
							            </div>
							        </div>
							    </td>
							</tr>
							<tr>
							    <td class="text-right td-gray">질문</td>
							    
							    <td class="ques_type_f${surveyQuesList.seq_no}" <c:if test="${surveyQuesList.ques_type_mf eq 'M'}">style="display:none;"</c:if>>
							        <input type="text" id="item_title_f${surveyQuesList.seq_no}" name="item_title_f${surveyQuesList.seq_no}" value="${surveyQuesList.ques_title }" class="form-control" maxlength="90" />
							    </td>
							    
							    <td class="ques_type_m${surveyQuesList.seq_no}" <c:if test="${surveyQuesList.ques_type_mf eq 'F'}">style="display:none;"</c:if>>
							        <div class="form-row inline-pd">
							            <div class="col" style="width: calc(100% - 100px);">
								            <input type="text" id="item_title_m${surveyQuesList.seq_no}" name="item_title_m${surveyQuesList.seq_no}" value="${surveyQuesList.ques_title }" class="form-control" maxlength="90"/>
								        </div>
								        <div class="col width100px">
								            <button type="button" class="btn btn-primary-gra" onclick="fnAddAnswer('${surveyQuesList.seq_no}');" style="width: 100%;"><i class="material-iconsadd"></i>예시추가</button>
								        </div>
							        </div>
							    </td>
							    
							</tr>
							<c:if test="${surveyQuesList.ques_type_mf eq 'F' }">
								<tr class="ques_type_m${surveyQuesList.seq_no}" id="answer${surveyQuesList.seq_no}_1" name="answer${surveyQuesList.seq_no}_1" style="display:none">
								    <td class="text-right td-gray">예시1</td>
								    <td>
								        <div class="form-row inline-pd">
								            <div class="col" style="width: calc(100% - 70px);">
									            <input type="text" id="ans_item${surveyQuesList.seq_no}_1" name="ans_item${surveyQuesList.seq_no}_1"  class="form-control" />
									        </div>
									        <div class="col width70px">
									            <button type="button" class="btn btn-primary-gra" onclick="fnDeleteAnswer('${surveyQuesList.seq_no}_1');" style="width: 100%;">삭제</button>
								            </div>
								        </div>
								    </td>
								</tr>
								<tr class="ques_type_m${surveyQuesList.seq_no}" id="answer${surveyQuesList.seq_no}_2" name="answer${surveyQuesList.seq_no}_2" style="display:none">
								    <td class="text-right td-gray">예시2</td>
								    <td>
								        <div class="form-row inline-pd">
								            <div class="col" style="width: calc(100% - 70px);">
									            <input type="text" id="ans_item${surveyQuesList.seq_no}_2" name="ans_item${surveyQuesList.seq_no}_2"  class="form-control" />
									        </div>
									        <div class="col width70px">
									            <button type="button" class="btn btn-primary-gra" onclick="fnDeleteAnswer('${surveyQuesList.seq_no}_2');" style="width: 100%;">삭제</button>
								            </div>
								        </div>
								    </td>
								</tr>
								<tr class="ques_type_m${surveyQuesList.seq_no}" id="answer${surveyQuesList.seq_no}_3" name="answer${surveyQuesList.seq_no}_3" style="display:none">
								    <td class="text-right td-gray">예시3</td>
								    <td>
								        <div class="form-row inline-pd">
								            <div class="col" style="width: calc(100% - 70px);">
									            <input type="text" id="ans_item${surveyQuesList.seq_no}_3" name="ans_item${surveyQuesList.seq_no}_3"  class="form-control" />
									        </div>
									        <div class="col width70px">
									            <button type="button" class="btn btn-primary-gra" onclick="fnDeleteAnswer('${surveyQuesList.seq_no}_3');" style="width: 100%;">삭제</button>
								            </div>
								        </div>
								    </td>
								</tr>
							</c:if>
							<c:forEach var="surveyQuesItemList" items="${surveyQuesItemList }" varStatus="status2">
								<c:if test="${surveyQuesList.ques_type_mf eq 'M' }">
									<c:if test="${surveyQuesList.seq_no eq surveyQuesItemList.ques_seq_no}">
									<tr class="ques_type_m${surveyQuesList.seq_no}" id="answer${surveyQuesList.seq_no}_${surveyQuesItemList.seq_no}" name="answer${surveyQuesList.seq_no}_${surveyQuesItemList.seq_no}" <c:if test="${surveyQuesList.ques_type_mf eq 'F'}">style="display:none;"</c:if> >
									    <td class="text-right td-gray">예시${surveyQuesItemList.seq_no}</td>
									    <td>
									        <div class="form-row inline-pd">
									            <div class="col" style="width: calc(100% - 70px);">
										            <input type="text" id="ans_item${surveyQuesList.seq_no}_${surveyQuesItemList.seq_no}" name="ans_item${surveyQuesList.seq_no}_${surveyQuesItemList.seq_no}" value="${surveyQuesItemList.item_title }" class="form-control" />
										        </div>
										        <div class="col width70px">
										            <button type="button" class="btn btn-primary-gra" onclick="fnDeleteAnswer('${surveyQuesList.seq_no}_${surveyQuesItemList.seq_no}');" style="width: 100%;">삭제</button>
									            </div>
									        </div>
									    </td>
									</tr>
									</c:if>
								</c:if>
							</c:forEach>
						</tbody>
					</c:forEach>
	            </table>
	        </div>
	        <div class="btn-group mt10">
	            <div class="right">
					<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="BOM_R"/></jsp:include>
				</div>
			</div>
		</div>
	</div>
	<!-- /팝업 -->
</form>
</body>
</html>
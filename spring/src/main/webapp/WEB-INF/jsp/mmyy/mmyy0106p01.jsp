<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : MY > MY > 휴가원 > null > 휴가원등록
-- 작성자 : 손광진
-- 최초 작성일 : 2020-07-17 10:18:27
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp" />
	<script type="text/javascript">
		$(document).ready(function() {
			
			fnTodayDate();
			
		});
	
		// 오늘날짜 세팅
		function fnTodayDate() {
			var today = $M.getCurrentDate("yyyyMMdd");
			
			var curDate = today.substring(0, 4) + "년 " + today.substring(4, 6) + "월 " + today.substring(6, 8) + "일";
			$("#curDate").text(curDate);
		}
		
		function goRequestApproval() {
			// validation check
	     	if($M.validation(document.main_form) === false) {
	     		return;
	     	};

			if ($M.getValue("day_cnt") == 0) {
				alert("휴가 기간을 확인해 주세요.");
				return;
			}

	     	var stYear  = $M.getValue("start_dt").substring(0, 4);
	     	var endYear = $M.getValue("end_dt").substring(0, 4);
	     	if(stYear != endYear) {
	     		alert("시작일과 종료일을 같은 연도로 입력해 주세요.");
	     		return;
	     	};
			// 날짜 검증
			if($M.checkRangeByFieldName("start_dt", "end_dt", true) === false) {
				return;
			};
			var param = {
				writer_appr_yn : $M.getValue("apprWriterYn1")
			}
			openApprReqPanel('fnResultAppr', $M.toGetParam(param));
		}
		
		// 결재요청 팝업 결과
		function fnResultAppr(item) {
			$M.setValue("save_mode", 'appr'); // 결재요청
			var frm = document.main_form;
			frm = $M.toValueForm(frm);
			
			// 결재라인의 상태를 변경함(라인만큼 split 한 후, 첫번째를 승인(자기 자신), 나머지를 처리전으로 변경)
			var memNoStr = $M.getValue("appr_mem_no_str");
			var apprStatusCdStr = memNoStr.split("#");
			var tempStatusArr = [];
			var finalStatusStr = "02";
			
			// 결재라인이 몇개인지 구함.
			// 혼자면 02로 하고 끝,
			if (apprStatusCdStr.length != 1) {
				// 아니면 첫번째 인덱스를 제외하고 02를 붙임
				for (var i = 1; i < apprStatusCdStr.length; ++i) {
					finalStatusStr+="#01";
					console.log(finalStatusStr);
				}
			}
			// 요청자의 writer_appr_yn를 변경(첫번째 writer_appr_yn_str)
			var strTemp = $M.getValue("writer_appr_yn_str");
			if (strTemp.length-1 == 0) {
				strTemp = item.writer_appr_yn;
			} else {
				strTemp = item.writer_appr_yn +  strTemp.substring(1); 
			}
			$M.setValue("writer_appr_yn_str", strTemp);
			$M.setHiddenValue(frm, "appr_memo", item.appr_memo); 
			console.log("appr_status_cd_str =>", finalStatusStr, "writer_appr_yn_str", strTemp, "appr_memo", item.appr_memo);
			$M.goNextPageAjax(this_page + "/save", frm, {method : 'POST'},
				function(result) {
					if(result.success) {
						fnClose();
		    			window.opener.goSearch();
					}
				}
			)
		}
		
		// 휴가원등록
		function goSave(code) {
			
		  	// validation check
	     	if($M.validation(document.main_form) === false) {
	     		return;
	     	};

			if ($M.getValue("day_cnt") == 0) {
				alert("휴가 기간을 확인해 주세요.");
				return;
			}
	     	
	     	var stYear  = $M.getValue("start_dt").substring(0, 4);
	     	var endYear = $M.getValue("end_dt").substring(0, 4);
	     	
	     	if(stYear != endYear) {
	     		alert("시작일과 종료일을 같은 연도로 입력해 주세요.");
	     		return;
	     	};
			
			// 날짜 검증
			if($M.checkRangeByFieldName("start_dt", "end_dt", true) === false) {
				return;
			};
			
			// 결재요청 팝업으로 분리로 인해 saveMode 사용불가
			/* var saveMode = code == 'appr' ? 'appr' : 'save';
			console.log(saveMode);
			$M.setValue("save_mode", saveMode); // 결재요청 */
			$M.setValue("save_mode", "save");
			
			var frm = document.main_form;
			frm = $M.toValueForm(frm);
			
			var msg 	  = code == 'appr' ? "결재요청 하시겠습니까?" : "저장하시겠습니까?";
			var resultMsg = code == 'appr' ? "정상적으로 결재처리 되었습니다." : "저장이 완료되었습니다.";
			
			$M.goNextPageAjaxMsg(msg, this_page + "/save", frm, {method : 'POST'},
				function(result) {
					if(result.success) {
						alert(resultMsg);
						fnClose();
		    			window.opener.goSearch();
					}
				}
			)
		}
		
		function fnGetHolidayCnt() {
			
			var holidayTypeCd 	= $M.nvl($M.getValue("holiday_type_cd"), "");
			var start_dt 		= $M.nvl($M.getValue("start_dt"), "");
			var end_dt 			= $M.nvl($M.getValue("end_dt"), "");
			
			// 필수값 확인
			if(holidayTypeCd === "" || start_dt === "" || end_dt === "") {
				return;
			};

			// 날짜 검증
			if($M.checkRangeByFieldName("start_dt", "end_dt", true) === false) {
				return;
			};
	
			var param = {
				"s_start_dt" 	: $M.getValue("start_dt"),
				"s_end_dt" 		: $M.getValue("end_dt"),
			};
	
			$M.goNextPageAjax(this_page + "/holidayCnt", $M.toGetParam(param), {method : "get"},
				function(result) {
					if(result.success) {
						var day_cnt = result.day_cnt;
						if(holidayTypeCd == "21" || holidayTypeCd == "22") {
							day_cnt = $M.toNum(result.day_cnt / 2);
						};
						$M.setValue("day_cnt", day_cnt);
						
					};
				}
			);	
			
		}

		// 22.11.15 Q&A 15065 휴가원 작성 수정
		function fnChangeEndDate() {
			$M.setValue("end_dt",$M.getValue("start_dt"));
			fnGetHolidayCnt();
		}
	
		function fnClose() {
			window.close();
		}
	</script>
</head>
<body class="bg-white">
	<form id="main_form" name="main_form">
		<!-- appr(결재요청 후 저장), save(저장) -->
		<input type="hidden" id="save_mode" name="save_mode" value="">
		<input type="hidden" id="mem_no" name="mem_no" value="${bean.mem_no}">
		<input type="hidden" id="org_code" name="org_code" value="${bean.org_code}">
		<!-- 팝업 -->
		<div class="popup-wrap width-100per">
			<!-- 타이틀영역 -->
			<div class="main-title">
				<jsp:include page="/WEB-INF/jsp/common/menuNavi.jsp" />
			</div>
			<!-- /타이틀영역 -->
			<div class="content-wrap">
				<div>
					<div class="title-wrap">
						<div class="left">
							<h4>휴가, 공가신청서</h4>
						</div>
						<!-- 결재영역 -->
						<div class="p10">
							<jsp:include page="/WEB-INF/jsp/common/apprHeader.jsp"></jsp:include>
						</div>
						<!-- /결재영역 -->
					</div>
					<!-- 폼테이블 -->
					<table class="table-border mt10">
						<colgroup>
							<col width="80px">
							<col width="">
							<col width="80px">
							<col width="">
						</colgroup>
						<tbody>
							<tr>
								<th class="text-right">성명</th>
								<td><input type="text" class="form-control width120px" readonly="readonly" value="${bean.kor_name}"></td>
								<th class="text-right">소속</th>
								<td><input type="text" class="form-control width120px" readonly="readonly" value="${bean.org_name}"></td>
							</tr>
							<tr>
								<th class="text-right essential-item">연락처</th>
								<td><input type="text" class="form-control essential-bg width120px" id="contact_no" name="contact_no" value="${fn:replace(bean.hp_no, '-', '')}" format="phone" placeholder="숫자만 입력" required="required" alt="핸드폰"></td>
								<th class="text-right">직책</th>
								<td><input type="text" class="form-control width120px" readonly="readonly" id="grade_name" name="grade_name" value="${bean.grade_name}">
									<input type="hidden" id="grade_cd" name="grade_cd" value="${bean.grade_cd}"></td>
									
							</tr>
							<tr>
								<th class="text-right essential-item">종류</th>
								<td colspan="3">
									<select class="form-control width100px" id="holiday_type_cd" name="holiday_type_cd" alt="휴가종류" onChange="fnGetHolidayCnt();" required="required">
										<option value="">- 선택 -</option>
										<c:forEach items="${codeMap['HOLIDAY_TYPE']}" var="item">
											<option value="${item.code_value}"
												${item.code_value == "0" ? 'selected' : '' }>${item.code_name}</option>
										</c:forEach>
									</select>
								</td>
							</tr>
							<tr>
								<th class="text-right essential-item">기간</th>
								<td colspan="3">
									<div class="form-row inline-pd">
										<div class="col width45px">시작일</div>
		                            	<div class="col-width120px">
		                                	<div class="input-group">
		                                    	<input type="text" class="form-control border-right-0 calDate" id="start_dt" name="start_dt" dateformat="yyyy-MM-dd" alt="시작일" value="" onChange="fnChangeEndDate();">
		                                    </div>
		                                </div>
		                                <div class="col-width16px">~</div>
		                                <div class="col-width120px">
		                                	<div class="input-group">
		                                    	<input type="text" class="form-control border-right-0 calDate" id="end_dt" name="end_dt" dateformat="yyyy-MM-dd" alt="종료일" value="" onChange="fnGetHolidayCnt();">
		                                    </div>
	                               	  	</div>
										<div class="col width120px">
											<input type="text" id="day_cnt" name="day_cnt" size="3" maxlength="2" value="" format="num" alt="휴가일수" required="required" disabled="disabled"> 일간
										</div>
									</div>
								</td>
							</tr>
							<tr>
								<th class="text-right essential-item">사유</th>
								<td colspan="3"><textarea class="form-control" style="height: 150px;" id="content" name="content" required="required" maxlength="40" alt="사유"></textarea></td>
							</tr>
						</tbody>
					</table>
					<!-- /폼테이블 -->
					<div class="contract-info pr">
						<p class="font-15 mb10">위와 같이 휴가를 신청 하오니 허락하여 주시기 바랍니다.</p>
						<p class="font-13 text-dark mb10" id="curDate"></p>
						<div class="contract-name text-left">
							<p class="mb5">소속 : ${SecureUser.org_name}</p>
							<p>이름 : ${SecureUser.kor_name}</p>
						</div>
					</div>
				</div>
				<!-- 휴가사용현황-->
				<div class="title-wrap mt10">
					<h4><b>${SecureUser.kor_name}</b>님 ${inputParam.s_current_year}년 휴가사용현황</h4>
				</div>
				<table class="table-border mt5">
					<colgroup>
						<col width="8.3333%">
						<col width="8.3333%">
						<col width="8.3333%">
						<col width="8.3333%">
						<col width="8.3333%">
						<col width="8.3333%">
						<col width="8.3333%">
						<col width="8.3333%">
						<col width="8.3333%">
						<col width="8.3333%">
						<col width="8.3333%">
						<col width="8.3333%">
					</colgroup>
					<thead>
					<tr>
						<th>국내출장</th>
						<th>국외출장</th>
						<th>종일휴가</th>
						<th>오전휴가</th>
						<th>오후휴가</th>
						<th>공가</th>
						<th>특별휴가</th>
						<th>무급휴가</th>
						<th>연간휴가일수</th>
						<th>연간사용일수</th>
						<th>미결신청일수</th>
						<th>잔여휴가일수</th>
					</tr>
					</thead>
					<tbody>
					<tr>
						<td class="text-center" id="">${memHoliday.days1}</td>
						<td class="text-center" id="">${memHoliday.days2}</td>
						<td class="text-center" id="">${memHoliday.days3}</td>
						<td class="text-center" id="">${memHoliday.days4}</td>
						<td class="text-center" id="">${memHoliday.days5}</td>
						<td class="text-center" id="">${memHoliday.days6}</td>
						<td class="text-center" id="">${memHoliday.days7}</td>
						<td class="text-center" id="">${memHoliday.days8}</td>
						<td class="text-center" id="">${memHoliday.issue_cnt}</td>
						<td class="text-center" id="">${memHoliday.total_use_day_cnt}</td>
						<td class="text-center" id="">${memHoliday.mi_proc_days}</td>
						<td class="text-center" id="">${memHoliday.remainder_day_cnt}</td>
					</tr>
					</tbody>
				</table>
				<div class="btn-group mt10">
					<div class="right">
						<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param
								name="pos" value="BOM_R" /></jsp:include>
					</div>
				</div>
			</div>
		</div>
		<!-- /팝업 -->
	</form>
</body>
</html>
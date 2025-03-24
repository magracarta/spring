<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : MY > MY > 휴가원 > null > 휴가원상세
-- 작성자 : 손광진
-- 최초 작성일 : 2020-07-17 10:18:27
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
	<script type="text/javascript">
	
		$(document).ready(function() {
			fnInitDate();
			fnInitModifyMode();
		});
	
		function fnInitModifyMode() {
			var apprStatusCd = $M.nvl($M.getValue("appr_proc_status_cd"), "");
			if(apprStatusCd == "05" || apprStatusCd == "06") {
				$("#contact_no").attr("readonly", true); // 연락처
				$("#holiday_type_cd").attr("disabled", true); // 휴가종류
				$("#start_dt").attr("disabled", true); // 휴가시작일
				$("#end_dt").attr("disabled", true); // 휴가종료일
				$("#day_cnt").attr("disabled", true); // 휴가일수
				$("#content").attr("disabled", true); // 사유	
			};
		}
		
		function fnInitDate() {
			var today = $M.getCurrentDate("yyyyMMdd");
	
			var curDate = today.substring(0, 4) + "년 " + today.substring(4, 6) + "월 " + today.substring(6, 8) + "일";
			var apply_date = $M.nvl($M.getValue("curDate"), "");
			if(apply_date == "") {
				$("#curDate").text(curDate);
			};
		}

		// 결재요청
		function goRequestApproval() {
			// goModify('requestAppr');
			
			// 결재요청팝업으로 변경
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
						alert("처리가 완료되었습니다.");
						window.location.reload();
		    			if (opener != null && opener.goSearch) {
		    				opener.goSearch();
		    			}
					}
				}
			)
		}
		
		// 결재처리
		function goApproval() {
			var param = {
				appr_job_seq : "${apprBean.appr_job_seq}",
				seq_no : "${apprBean.seq_no}"
			};
			$M.setValue("save_mode", "approval"); // 승인
			openApprPanel("goApprovalResult", $M.toGetParam(param));
		}

		// 종결처리
		function goApprovalEnd() {
			var param = {
				appr_job_seq : "${apprBean.appr_job_seq}",
				seq_no : "${apprBean.seq_no}",
				appr_end_only : 'Y',
			};
			openApprPanel("goApprovalResult", $M.toGetParam(param));
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

		
		// 휴가원등록
		function goModify(appr) {
			
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
			
			if (appr != undefined) {
				$M.setValue("save_mode", "appr"); // 결재요청
				if (confirm("결재요청 하시겠습니까?") == false) {
					return false;
				}
			} else {
				$M.setValue("save_mode", "save"); // 저장
				if (confirm("저장하시겠습니까?") == false) {
					return false;
				}
			}
			
			if($M.nvl($M.getValue("holiday_type_cd"), "") === "") {
				alert("휴가 종류를 선택해주세요.")
				return;
			};
			
			if($M.nvl($M.getValue("day_cnt"), "") === "") {
				alert("휴가 일수를 입력해주세요.")
				return;
			};
			
			if($M.nvl($M.getValue("content"), "") === "") {
				alert("사유를 입력해주세요.")
				return;
			};
			
			var frm = document.main_form;
			frm = $M.toValueForm(frm);
		
			$M.goNextPageAjax(this_page + "/save", frm, {method : 'POST'},
				function(result) {
					if(result.success) {
			    		if (appr != undefined) {
							alert("처리가 완료됐습니다.");	
			    		} else {
			    			alert("수정이 완료되었습니다.");
			    		};
						location.reload();
					}
				}
			)
		}
		
		// 상신취소
		function goApprCancel() {
			var param = {
				appr_job_seq : "${apprBean.appr_job_seq}",
				seq_no : "${apprBean.seq_no}",
				appr_cancel_yn : "Y"
			};
			openApprPanel("goApprovalResult", $M.toGetParam(param));
		}
		
		// 결재처리 결과
		function goApprovalResult(result) {
			// 반려이면 페이지 리로딩
			if(result.appr_status_cd == '03') {
				$M.goNextPageAjax('/session/check', '', {method : 'GET'},
						function(result) {
					    	if(result.success) {
					    		alert("반려가 완료되었습니다.");
								location.reload();
							}
						}
					);
			}
			else{
	    		$M.goNextPageAjax('/session/check', '', {method : 'GET'},
						function(result) {
					    	if(result.success) {
								var param = {
									memHolidaySeq : $M.nvl($M.getValue("mem_holiday_seq"), ""),
								};

								// Q&A [14310] : 휴가 상세 테이블에 데이터 저장
								$M.goNextPageAjax(this_page + '/holidayDtlSave', $M.toGetParam(param), {method : 'POST'},
										function(result) {
											if(result.success) {
												location.reload();
											} else {
												alert("처리에 오류가 발생하였습니다.");
												location.reload();
											}
										}
								);
							}
						}
					);
			}
		}
		
		// 삭제
		function goRemove() {

			var apprProcStatusCd 	= $M.nvl($M.getValue("appr_proc_status_cd"), "");
			var memHolidaySeq 		= $M.nvl($M.getValue("mem_holiday_seq"), "");
			
			$M.goNextPageAjaxRemove(this_page + "/" + memHolidaySeq  + "/remove", "", {method : 'POST'},
				function(result) {
		    		if(result.success) {
		    			fnClose();
		    			opener.goSearch();
					}
				}
			);
		}


		function fnClose() {
			window.close();
		}
	</script>
</head>
<body class="bg-white">
	<form id="main_form" name="main_form">
		<!-- 팝업 -->
		<div class="popup-wrap width-100per">
			<input type="hidden" id="save_mode" name="save_mode"> <!-- appr(결재요청 후 저장), save(저장) -->
			<input type="hidden" id="appr_job_seq" name="appr_job_seq" value="${memHolidayInfo.appr_job_seq}">
			<input type="hidden" id="mem_no" name="mem_no" value="${memHolidayInfo.mem_no}">
			<input type="hidden" id="org_code" name="org_code" value="${memHolidayInfo.org_code}">
			<input type="hidden" id="grade_cd" name="grade_cd" value="${memHolidayInfo.grade_cd}">
			<input type="hidden" id="mem_holiday_seq" name="mem_holiday_seq" value="${memHolidayInfo.mem_holiday_seq}">
			<input type="hidden" id="appr_proc_status_cd" name="appr_proc_status_cd" value="${memHolidayInfo.appr_proc_status_cd}">
			<!-- 타이틀영역 -->
			<div class="main-title">
				<jsp:include page="/WEB-INF/jsp/common/menuNavi.jsp"/>
			</div>
			<!-- /타이틀영역 -->
			<div class="content-wrap">
				<div>
					<div class="title-wrap">
						<div class="left">
							<h4>휴가원 상세</h4>
						</div>
						<!-- 결재영역 -->
						<div class="p10" style="margin-left: 10px;">
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
							<td>
								<input type="text" class="form-control width120px" readonly="readonly" value="${memHolidayInfo.mem_name}">
							</td>
							<th class="text-right">소속</th>
							<td>
								<input type="text" class="form-control width120px" readonly="readonly" value="${memHolidayInfo.org_name}">
							</td>
						</tr>
						<tr>
							<th class="text-right essential-item">연락처</th>
							<td>
								<input type="text" class="form-control width120px" id="contact_no" name="contact_no" value="${memHolidayInfo.contact_no}" format="phone" placeholder="숫자만 입력" required="required" alt="핸드폰">
							</td>
							<th class="text-right">직책</th>
							<td>
								<input type="text" class="form-control width120px" readonly="readonly" value="${memHolidayInfo.grade_name}">
							</td>
						</tr>
						<tr>
							<th class="text-right essential-item">종류</th>
							<td colspan="3">
								<select class="form-control width120px" id="holiday_type_cd" name="holiday_type_cd" alt="휴가 종류" required="required" onChange="fnGetHolidayCnt();">
									<option value="">- 선택 -</option>
									<c:forEach items="${codeMap['HOLIDAY_TYPE']}" var="item">
										<option value="${item.code_value}" ${item.code_value == memHolidayInfo.holiday_type_cd ? 'selected' : '' } >${item.code_name}</option>
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
	                                    	<input type="text" class="form-control border-right-0 calDate" id="start_dt" name="start_dt" dateformat="yyyy-MM-dd" alt="시작일" value="${memHolidayInfo.start_dt}" onChange="fnGetHolidayCnt();">
	                                    </div>
	                                </div>
	                                <div class="col-width16px">~</div>
	                                <div class="col width45px">종료일</div>
	                                <div class="col-width120px">
	                                	<div class="input-group">
	                                    	<input type="text" class="form-control border-right-0 calDate" id="end_dt" name="end_dt" dateformat="yyyy-MM-dd" alt="종료일" value="${memHolidayInfo.end_dt}" onChange="fnGetHolidayCnt();">
	                                    </div>
                               	  	</div>
									<div class="col width120px">
										<input type="text" id="day_cnt" name="day_cnt" size="3" maxlength="2" format="num" alt="휴가일수" value="${memHolidayInfo.day_cnt}" required="required"> 일간
									</div>
								</div>
							</td>
						</tr>
						<tr>
							<th class="text-right essential-item">사유</th>
							<td>
								<textarea class="form-control" style="height: 150px;" id="content" name="content" required="required" maxlength="40" alt="사유">${memHolidayInfo.content}</textarea>
							</td>
							<th class="text-right">결재자의견</th>
							<td>
								<div class="fixed-table-container" style="width: 100%; height: 100%;"> <!-- height값 인라인 스타일로 주면 타이틀 영역이 고정됨  -->
									<div class="fixed-table-wrapper">
										<table class="table-border doc-table md-table">
											<colgroup>
												<col width="40px">
												<col width="140px">
												<col width="55px">
												<col width="">
											</colgroup>
											<thead>
											<!-- 퍼블리싱 파일의 important 속성 때문에 dev에 선언한 클래스가 안되서 인라인 CSS로함 -->
											<tr><th class="th" style="font-size: 12px !important">구분</th>
												<th class="th" style="font-size: 12px !important">결재일시</th>
												<th class="th" style="font-size: 12px !important">담당자</th>
												<th class="th" style="font-size: 12px !important">특이사항</th>
											</tr></thead>
											<tbody>
											<c:forEach var="list" items="${apprMemoList}">
												<tr>
													<td class="td" style="text-align: center; font-size: 12px !important">${list.appr_status_name }</td>
													<td class="td" style="font-size: 12px !important">${list.proc_date }</td>
													<td class="td" style="text-align: center; font-size: 12px !important">${list.appr_mem_name }</td>
													<td class="td" style="font-size: 12px !important">${list.memo }</td>
												</tr>
											</c:forEach>
											</tbody>
										</table>
									</div>
								</div>
							</td>
						</tr>
						</tbody>
					</table>
					<!-- /폼테이블 -->
					<div class="contract-info pr">
						<p class="font-15 mb10">위와 같이 휴가를 신청 하오니 허락하여 주시기 바랍니다.</p>
						<c:set var = "apply_date" value="${memHolidayInfo.apply_date}"/>
					    <c:set var = "apply_year" 	  value="${fn:substring(apply_date, 0, 4)}"/>
					    <c:set var = "apply_month" 	  value="${fn:substring(apply_date, 5, 7)}"/>
					    <c:set var = "apply_day" 	  value="${fn:substring(apply_date, 8, 12)}"/>
						<p class="font-13 text-dark mb10">${apply_year}년 ${apply_month}월  ${apply_day}일</p>
						<div class="contract-name text-left">
							<p class="mb5">소속 : ${memHolidayInfo.org_name}</p>
							<p>이름 : ${memHolidayInfo.mem_name}</p>
						</div>
					</div>
				</div>
				<!-- 휴가사용현황-->
				<div class="title-wrap mt10">
					<h4><b>${memHolidayInfo.mem_name}</b>님 ${apply_year}년 휴가사용현황</h4>
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
						<!-- 인사담당자는 삭제가능, 유정은(관리 파트장권한), 관리 팀장, 채평석, 김태공(서비스부서장)  -->
						<c:if test="${memHolidayInfo.appr_proc_status_cd eq '05' and page.fnc.F00622_001 eq 'Y'}">
							<button type="button" class="btn btn-info" id="_goRemove" name="_goRemove" onclick="javascript:goRemove()">삭제</button>
						</c:if>
						<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="BOM_R"/><jsp:param name="appr_yn" value="Y"/></jsp:include>
					</div>
				</div>
			</div>
		</div>
		<!-- /팝업 -->
	</form>
</body>
</html>
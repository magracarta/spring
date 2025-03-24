<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp" /><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt"%><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions"%><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%><%@ taglib uri="http://www.springframework.org/tags" prefix="spring"%><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 회계 > 인사 > 인사관리 > null > 서비스 업무능력 평가
-- 작성자 : 성현우
-- 최초 작성일 : 2020-07-17 19:54:29
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
	<script type="text/javascript">
	
		// 첨부파일의 index 변수
		var fileIndex = 1;
		// 첨부할 수 있는 파일의 개수
		var fileCount = 1;
		
		var hrMap = ${hrMap};
		$(document).ready(function () {
			if("${save_yn}" == "N") {
				$("#_goSave").hide();
			}
			
			if ("${inputParam.show_yn}" == "Y" || "${page.fnc.F02095_001}" == "Y") {
				$("#_goSave").addClass("dpn");
			}

			// 메이커별 합계 계산
			$.each($("input:radio"), function (index, item) {
				if ($(this).prop('checked')) {
					// 메이커별 합계 계산
					fnMakerTotalPrice($(this).attr('name'), $(this).val());
				}
			});

			$("input:radio").click(function () {
				// 레벨/합계 계산
				fnTotalPrice();
				// 메이커별 합계 계산
				fnMakerTotalPrice(this.name, this.value);
			});
			
			setFileInfo($M.getValue("file_seq"), $M.getValue("file_name"));
		});

		// 초기화
		function fnReset(makerId) {
			$("input[name=" + makerId + "]").prop("checked", false);
			fnMakerTotalPrice(makerId, 0);
			fnTotalPrice();
		}

		// 메이커별 합계 계산
		function fnMakerTotalPrice(name, value) {
			var nameVal = name + "_eval_amt";
			var value = $M.toNum(value * $M.toNum($M.getValue("grade_salary_amt")));
			$M.setValue("eval_amt_" + name, value);
			$("#" + nameVal + "").text($M.setComma(value) == 0 ? '' : $M.setComma(value));
		}

		// 레벨/합계 계산
		function fnTotalPrice() {
			var totalPoint = 0;
			$.each($("input:radio"), function (index, item) {
				if ($(this).prop('checked')) {
					totalPoint += $M.toNum($(this).val());
				}
			});
			
			var biz = hrMap[totalPoint] ? hrMap[totalPoint] : "";
			var bizCode = biz ? biz[0].biz_code : "";
			var salaryAmt = biz ? biz[0].salary_amt : "";
			
			$M.setValue("biz_level", totalPoint);
			$M.setValue("biz_code", bizCode);
			$M.setValue("salary_amt", salaryAmt);
		}

		function fnSettingData() {
			var makerHrSvcArray = [];
			var evalGradeArray = [];
			var evalAmtArray = [];

			if ($M.getValue("27") != "") {
				makerHrSvcArray.push("27");
				evalGradeArray.push($M.getValue("27"));
				evalAmtArray.push($M.getValue("eval_amt_27"));
			}

			if ($M.getValue("02") != "") {
				makerHrSvcArray.push("02");
				evalGradeArray.push($M.getValue("02"));
				evalAmtArray.push($M.getValue("eval_amt_02"));
			}

			if ($M.getValue("42") != "") {
				makerHrSvcArray.push("42");
				evalGradeArray.push($M.getValue("42"));
				evalAmtArray.push($M.getValue("eval_amt_42"));
			}

			if ($M.getValue("68_01") != "") {
				makerHrSvcArray.push("68_01");
				evalGradeArray.push($M.getValue("68_01"));
				evalAmtArray.push($M.getValue("eval_amt_68_01"));
			}

			if ($M.getValue("68_02") != "") {
				makerHrSvcArray.push("68_02");
				evalGradeArray.push($M.getValue("68_02"));
				evalAmtArray.push($M.getValue("eval_amt_68_02"));
			}

			if ($M.getValue("94_01") != "") {
				makerHrSvcArray.push("94_01");
				evalGradeArray.push($M.getValue("94_01"));
				evalAmtArray.push($M.getValue("eval_amt_94_01"));
			}

			if ($M.getValue("94_02") != "") {
				makerHrSvcArray.push("94_02");
				evalGradeArray.push($M.getValue("94_02"));
				evalAmtArray.push($M.getValue("eval_amt_94_02"));
			}

			if ($M.getValue("101") != "") {
				makerHrSvcArray.push("101");
				evalGradeArray.push($M.getValue("101"));
				evalAmtArray.push($M.getValue("eval_amt_101"));
			}

			if ($M.getValue("105") != "") {
				makerHrSvcArray.push("105");
				evalGradeArray.push($M.getValue("105"));
				evalAmtArray.push($M.getValue("eval_amt_105"));
			}

			$M.setValue("maker_hr_svc_cd_str", makerHrSvcArray);
			$M.setValue("maker_hr_svc_cd_str", $M.getValue("maker_hr_svc_cd_str").replaceAll(",", "#"));
			$M.setValue("eval_grade_str", evalGradeArray);
			$M.setValue("eval_grade_str", $M.getValue("eval_grade_str").replaceAll(",", "#"));
			$M.setValue("eval_amt_str", evalAmtArray);
			$M.setValue("eval_amt_str", $M.getValue("eval_amt_str").replaceAll(",", "#"));
		}

		// 저장
		function goSave() {
			var minBizLevel = $M.toNum($M.getValue("min_biz_level"));
			var maxBizLevel = $M.toNum($M.getValue("max_biz_level"));
			var bizLevel = $M.toNum($M.getValue("biz_level"));
			
			var totalPoint = 0;
			$.each($("input:radio"), function (index, item) {
				if ($(this).prop('checked')) {
					totalPoint += $M.toNum($(this).val());
				}
			});
			
			if (minBizLevel != 0) {
				if (totalPoint < minBizLevel) {
					alert("해당 직군의 최소 레벨은 LA" + minBizLevel +"입니다.\nLA" + minBizLevel +" 이상으로 설정 해 주세요.");
					return false;
				}
				
				if (totalPoint > maxBizLevel) {
					if (confirm("해당 직군의 최대 레벨을 초과하였습니다.\n최대레벨 [LA"+ maxBizLevel +"] 으로 적용하시겠습니까 ?") == false) {
						return false;
					} else {
						// 직군에 설정된 최대값 초과시 최대값으로 적용
						var biz = hrMap[maxBizLevel] ? hrMap[maxBizLevel] : "";
						var bizCode = biz ? biz[0].biz_code : "";
						var salaryAmt = biz ? biz[0].salary_amt : "";
						
						$M.setValue("biz_level", maxBizLevel);
						$M.setValue("biz_code", bizCode);
						$M.setValue("salary_amt", salaryAmt);
					}
				}
			}
			
			fnSettingData();

			var frm = $M.toValueForm(document.main_form);
			$M.goNextPageAjaxSave(this_page + "/save", frm, {method: "POST"},
					function (result) {
						if (result.success) {
							try {
								opener.${inputParam.parent_js_name}(result.bean);
								window.close();
							} catch (e) {
								alert("호출 페이지에서 ${inputParam.parent_js_name}(row) 함수를 구현해주세요.");

							}
						}
					}
			);
		}

		// 닫기
		function fnClose() {
			window.close();
		}

		function setFileInfo(fileSeq, fileName) {
			if (fileSeq != "" && fileSeq != 0 && fileSeq != undefined) {
				var str = ''; 
				str += '<div class="hr_file_' + fileIndex + '" style="float:left; display:block;">';
				str += '<a href="javascript:fileDownload('+fileSeq+');" style="color: blue;">' + fileName + '</a>&nbsp;';
				str += '<input type="hidden" name="file_seq" value="' + fileSeq + '"/>';
				str += '&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;';
				str += '</div>';
				$('.hr_file_div').append(str);
			}
		}
	</script>
</head>
<body class="bg-white">
<form id="main_form" name="main_form">
	<input type="hidden" id="mem_no" name="mem_no" value="${inputParam.mem_no}"/>
	<input type="hidden" id="eval_year" name="eval_year" value="${inputParam.eval_year}"/>
	<input type="hidden" id="mem_band_item_cd" name="mem_band_item_cd" value="${inputParam.mem_band_item_cd}"/>
	<input type="hidden" id="seq_no" name="seq_no" value="${inputParam.seq_no}"/>
	<input type="hidden" id="adjust_seq_no" name="adjust_seq_no" value="${inputParam.adjust_seq_no}"/>
	<input type="hidden" name="grade_salary_amt" id="grade_salary_amt" value="${data.grade_salary_amt}">
	<input type="hidden" name="file_seq" id="file_seq" value="${file_seq}">
	<input type="hidden" name="file_name" id="file_name" value="${file_name}">
	<input type="hidden" name="min_biz_level" id="min_biz_level" value="${min_biz_level}">
	<input type="hidden" name="max_biz_level" id="max_biz_level" value="${max_biz_level}">

	<!-- 팝업 -->
	<div class="popup-wrap width-100per">
		<!-- 타이틀영역 -->
		<div class="main-title">
			<jsp:include page="/WEB-INF/jsp/common/menuNavi.jsp"/>
		</div>
		<!-- /타이틀영역 -->
		<div class="content-wrap">
			<div>
				<div class="title-wrap">
					<h4>
						평균 상승 연봉 : <span>${data.grade_salary_amt}원</span>
					</h4>
					&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
					<div class="hr_file_div" style="width:200px;">
					</div>					
					<div class="btn-group">
						<div class="right dpf">
							<c:if test="${min_biz_level ne ''}">
								<div class="mr10 text-warning">
									직군 레벨범위 : LV${min_biz_level} ~ LV${max_biz_level}
								</div>	
							</c:if>
							<c:if test="${min_biz_level eq ''}">
								<div class="mr10 text-warning">
									직군 레벨범위 미설정
								</div>	
							</c:if>
							<div class="mr10">
								현재레벨 : <span class="bul-red bul-sm"></span>
							</div>
							<div class="mr10">
								희망레벨 : <span class="bul-blue bul-sm"></span>
							</div>
							<div class="mr10">
								상사평가 : <span class="bul-green bul-sm"></span>
							</div>
							<div class="mr5">
								조정 : <span class="bul-yellow bul-sm"></span>
							</div>
							<div class="ver-line mr10">레벨/합계 :</div>
							<input type="text" class="text-center width60px" id="biz_code" name="biz_code" readonly="readonly" value="${inputParam.biz_code}">
							<span style="width: 12px; text-align: center;">/</span>
							<input type="text" class="text-center width100px" id="salary_amt" name="salary_amt" format="decimal" readonly="readonly" value="${inputParam.salary_amt}">
						</div>
					</div>
				</div>
			</div>

			<!-- 폼테이블 -->
			<div style="overflow-x: scroll;">
				<table class="table-border mt10 table-fixed">
					<colgroup>
						<col width="70px">
						<col width="120px">
						<col width="100px">
						<col width="60px">

						<col width="90px">
						<col width="90px">
						<col width="90px">
						<col width="90px">
						<col width="90px">
						<col width="90px">
						<col width="90px">
						<col width="90px">
						<col width="90px">
						<col width="90px">
						<col width="90px">
						<col width="90px">
						<col width="90px">
						<col width="90px">
						<col width="90px">
						<col width="90px">
						<col width="90px">
						<col width="90px">
					</colgroup>
					<thead>
					<tr>
						<th>메이커구분</th>
						<th>메이커명</th>
						<th>합계</th>
						<th>초기화</th>
						<th>레벨1</th>
						<th>레벨2</th>
						<th>레벨3</th>
						<th>레벨4</th>
						<th>레벨5</th>
						<th>레벨6</th>
						<th>레벨7</th>
						<th>레벨8</th>
						<th>레벨9</th>
						<th>레벨10</th>
						<th>레벨11</th>
						<th>레벨12</th>
						<th>레벨13</th>
						<th>레벨14</th>
						<th>레벨15</th>
						<th>레벨16</th>
						<th>레벨17</th>
						<th>레벨18</th>
					</tr>
					</thead>
					<tbody>
					<tr>
						<th>기본</th>
						<td class="text-center">얀마</td>
						<c:set var="bean" value="${evalMap['27']}"/>
						<td class="text-right" name="${bean.maker_hr_svc_cd}_eval_amt" id="${bean.maker_hr_svc_cd}_eval_amt"></td>
						<td class="text-center">
							<button type="button" class="btn btn-primary-gra" onclick="javascript:fnReset('${bean.maker_hr_svc_cd}');">초기화</button>
						</td>
						<c:forEach var="item" begin="1" end="18">
							<c:set var="key">level_${item}</c:set>
							<td>
								<div class="level-state">
									<div class="state-bul ${bean.show_yn eq 'N' ? 'invisible' : '' }">
										<!-- 상태표시가 없을 경우 "invisible" 클래스 추가-->
										<c:if test="${inputParam.level_index ne '0' and bean.eval_grade_0 eq item}">
											<span class="bul-red bul-sm"></span>
										</c:if>
										<c:if test="${inputParam.level_index ne '1' and bean.eval_grade_1 eq item}">
											<span class="bul-blue bul-sm"></span>
										</c:if>
										<c:if test="${inputParam.level_index ne '2' and bean.eval_grade_2 eq item}">
											<span class="bul-green bul-sm"></span>
										</c:if>
										<c:if test="${inputParam.level_index ne '3' and bean.eval_grade_3 eq item}">
											<span class="bul-yellow bul-sm"></span>
										</c:if>
									</div>
									<div class="form-check form-check-inline">
										<label class="form-check-label mr5" for="${bean.maker_hr_svc_cd}${item}">${bean[key]}</label>
										<input class="form-check-input" type="radio" id="${bean.maker_hr_svc_cd}${item}" name="${bean.maker_hr_svc_cd}" value="${item}" ${bean.sel_val eq item ? 'checked=checked' : ''}>
									</div>
								</div>
							</td>
						</c:forEach>
					</tr>

					<tr>
						<th rowspan="3">일반</th>
						<td class="text-center">겔</td>
						<c:set var="bean" value="${evalMap['02']}"/>
						<td class="text-right" name="${bean.maker_hr_svc_cd}_eval_amt" id="${bean.maker_hr_svc_cd}_eval_amt"></td>
						<td class="text-center">
							<button type="button" class="btn btn-primary-gra" onclick="javascript:fnReset('${bean.maker_hr_svc_cd}');">초기화</button>
						</td>
						<c:forEach var="item" begin="1" end="18">
							<c:set var="key">level_${item}</c:set>
							<td>
								<div class="level-state">
									<div class="state-bul ${bean.show_yn eq 'N' ? 'invisible' : '' }">
										<!-- 상태표시가 없을 경우 "invisible" 클래스 추가-->
										<c:if test="${inputParam.level_index ne '0' and bean.eval_grade_0 eq item}">
											<span class="bul-red bul-sm"></span>
										</c:if>
										<c:if test="${inputParam.level_index ne '1' and bean.eval_grade_1 eq item}">
											<span class="bul-blue bul-sm"></span>
										</c:if>
										<c:if test="${inputParam.level_index ne '2' and bean.eval_grade_2 eq item}">
											<span class="bul-green bul-sm"></span>
										</c:if>
										<c:if test="${inputParam.level_index ne '3' and bean.eval_grade_3 eq item}">
											<span class="bul-yellow bul-sm"></span>
										</c:if>
									</div>
									<div class="form-check form-check-inline">
										<c:if test="${item lt 9}">
											<label class="form-check-label mr5" for="${bean.maker_hr_svc_cd}${item}">${bean[key]}</label>
											<input class="form-check-input" type="radio" id="${bean.maker_hr_svc_cd}${item}" name="${bean.maker_hr_svc_cd}" value="${item}" ${bean.sel_val eq item ? 'checked=checked' : ''}>
										</c:if>
									</div>
								</div>
							</td>
						</c:forEach>
					</tr>

					<tr>
						<td class="text-center">햄</td>
						<c:set var="bean" value="${evalMap['42']}"/>
						<td class="text-right" name="${bean.maker_hr_svc_cd}_eval_amt" id="${bean.maker_hr_svc_cd}_eval_amt"></td>
						<td class="text-center">
							<button type="button" class="btn btn-primary-gra" onclick="javascript:fnReset('${bean.maker_hr_svc_cd}');">초기화</button>
						</td>
						<c:forEach var="item" begin="1" end="18">
							<c:set var="key">level_${item}</c:set>
							<td>
								<div class="level-state">
									<div class="state-bul ${bean.show_yn eq 'N' ? 'invisible' : '' }">
										<!-- 상태표시가 없을 경우 "invisible" 클래스 추가-->
										<c:if test="${inputParam.level_index ne '0' and bean.eval_grade_0 eq item}">
											<span class="bul-red bul-sm"></span>
										</c:if>
										<c:if test="${inputParam.level_index ne '1' and bean.eval_grade_1 eq item}">
											<span class="bul-blue bul-sm"></span>
										</c:if>
										<c:if test="${inputParam.level_index ne '2' and bean.eval_grade_2 eq item}">
											<span class="bul-green bul-sm"></span>
										</c:if>
										<c:if test="${inputParam.level_index ne '3' and bean.eval_grade_3 eq item}">
											<span class="bul-yellow bul-sm"></span>
										</c:if>
									</div>
									<div class="form-check form-check-inline">
										<c:if test="${item lt 9}">
											<label class="form-check-label mr5" for="${bean.maker_hr_svc_cd}${item}">${bean[key]}</label>
											<input class="form-check-input" type="radio" id="${bean.maker_hr_svc_cd}${item}" name="${bean.maker_hr_svc_cd}" value="${item}" ${bean.sel_val eq item ? 'checked=checked' : ''}>
										</c:if>
									</div>
								</div>
							</td>
						</c:forEach>
					</tr>

					<tr>
						<td class="text-center">마니또(MT.AWP)</td>
						<c:set var="bean" value="${evalMap['68_01']}"/>
						<td class="text-right" name="${bean.maker_hr_svc_cd}_eval_amt" id="${bean.maker_hr_svc_cd}_eval_amt"></td>
						<td class="text-center">
							<button type="button" class="btn btn-primary-gra" onclick="javascript:fnReset('${bean.maker_hr_svc_cd}');">초기화</button>
						</td>
						<c:forEach var="item" begin="1" end="18">
							<c:set var="key">level_${item}</c:set>
							<td>
								<div class="level-state">
									<div class="state-bul ${bean.show_yn eq 'N' ? 'invisible' : '' }">
										<!-- 상태표시가 없을 경우 "invisible" 클래스 추가-->
										<c:if test="${inputParam.level_index ne '0' and bean.eval_grade_0 eq item}">
											<span class="bul-red bul-sm"></span>
										</c:if>
										<c:if test="${inputParam.level_index ne '1' and bean.eval_grade_1 eq item }">
											<span class="bul-blue bul-sm"></span>
										</c:if>
										<c:if test="${inputParam.level_index ne '2' and bean.eval_grade_2 eq item }">
											<span class="bul-green bul-sm"></span>
										</c:if>
										<c:if test="${inputParam.level_index ne '3' and bean.eval_grade_3 eq item }">
											<span class="bul-yellow bul-sm"></span>
										</c:if>
									</div>
									<div class="form-check form-check-inline">
										<c:if test="${item lt 9}">
											<label class="form-check-label mr5" for="${bean.maker_hr_svc_cd}${item}">${bean[key]}</label>
											<input class="form-check-input" type="radio" id="${bean.maker_hr_svc_cd}${item}" name="${bean.maker_hr_svc_cd}" value="${item}" ${bean.sel_val eq item ? 'checked=checked' : ''}>
										</c:if>
									</div>
								</div>
							</td>
						</c:forEach>
					</tr>

					<tr>
						<th rowspan="5">특수</th>
						<td class="text-center">마니또(MRT)</td>
						<c:set var="bean" value="${evalMap['68_02']}"/>
						<td class="text-right" name="${bean.maker_hr_svc_cd}_eval_amt" id="${bean.maker_hr_svc_cd}_eval_amt"></td>
						<td class="text-center">
							<button type="button" class="btn btn-primary-gra" onclick="javascript:fnReset('${bean.maker_hr_svc_cd}');">초기화</button>
						</td>
						<c:forEach var="item" begin="1" end="18">
							<c:set var="key">level_${item}</c:set>
							<td>
								<div class="level-state">
									<div class="state-bul ${bean.show_yn eq 'N' ? 'invisible' : '' }">
										<!-- 상태표시가 없을 경우 "invisible" 클래스 추가-->
										<c:if test="${inputParam.level_index ne '0' and bean.eval_grade_0 eq item}">
											<span class="bul-red bul-sm"></span>
										</c:if>
										<c:if test="${inputParam.level_index ne '1' and bean.eval_grade_1 eq item}">
											<span class="bul-blue bul-sm"></span>
										</c:if>
										<c:if test="${inputParam.level_index ne '2' and bean.eval_grade_2 eq item}">
											<span class="bul-green bul-sm"></span>
										</c:if>
										<c:if test="${inputParam.level_index ne '3' and bean.eval_grade_3 eq item}">
											<span class="bul-yellow bul-sm"></span>
										</c:if>
									</div>
									<div class="form-check form-check-inline">
										<c:if test="${item lt 9}">
											<label class="form-check-label mr5" for="${bean.maker_hr_svc_cd}${item}">${bean[key]}</label>
											<input class="form-check-input" type="radio" id="${bean.maker_hr_svc_cd}${item}" name="${bean.maker_hr_svc_cd}" value="${item}" ${bean.sel_val eq item ? 'checked=checked' : ''}>
										</c:if>
									</div>
								</div>
							</td>
						</c:forEach>
					</tr>

					<tr>
						<td class="text-center">빌트겐(MILL)</td>
						<c:set var="bean" value="${evalMap['94_01']}"/>
						<td class="text-right" name="${bean.maker_hr_svc_cd}_eval_amt" id="${bean.maker_hr_svc_cd}_eval_amt"></td>
						<td class="text-center">
							<button type="button" class="btn btn-primary-gra" onclick="javascript:fnReset('${bean.maker_hr_svc_cd}');">초기화</button>
						</td>
						<c:forEach var="item" begin="1" end="18">
							<c:set var="key">level_${item}</c:set>
							<td>
								<div class="level-state">
									<div class="state-bul ${bean.show_yn eq 'N' ? 'invisible' : ''}">
										<!-- 상태표시가 없을 경우 "invisible" 클래스 추가-->
										<c:if test="${inputParam.level_index ne '0' and bean.eval_grade_0 eq item}">
											<span class="bul-red bul-sm"></span>
										</c:if>
										<c:if test="${inputParam.level_index ne '1' and bean.eval_grade_1 eq item}">
											<span class="bul-blue bul-sm"></span>
										</c:if>
										<c:if test="${inputParam.level_index ne '2' and bean.eval_grade_2 eq item}">
											<span class="bul-green bul-sm"></span>
										</c:if>
										<c:if test="${inputParam.level_index ne '3' and bean.eval_grade_3 eq item}">
											<span class="bul-yellow bul-sm"></span>
										</c:if>
									</div>
									<div class="form-check form-check-inline">
										<c:if test="${item lt 9}">
											<label class="form-check-label mr5" for="${bean.maker_hr_svc_cd}${item}">${bean[key]}</label>
											<input class="form-check-input" type="radio" id="${bean.maker_hr_svc_cd}${item}" name="${bean.maker_hr_svc_cd}" value="${item}" ${bean.sel_val eq item ? 'checked=checked' : ''}>
										</c:if>
									</div>
								</div>
							</td>
						</c:forEach>
					</tr>

					<tr>
						<td class="text-center">빌트겐(SP)</td>
						<c:set var="bean" value="${evalMap['94_02']}"/>
						<td class="text-right" name="${bean.maker_hr_svc_cd}_eval_amt" id="${bean.maker_hr_svc_cd}_eval_amt"></td>
						<td class="text-center">
							<button type="button" class="btn btn-primary-gra" onclick="javascript:fnReset('${bean.maker_hr_svc_cd}');">초기화</button>
						</td>
						<c:forEach var="item" begin="1" end="18">
							<c:set var="key">level_${item}</c:set>
							<td>
								<div class="level-state">
									<div class="state-bul ${bean.show_yn eq 'N' ? 'invisible' : '' }">
										<!-- 상태표시가 없을 경우 "invisible" 클래스 추가-->
										<c:if test="${inputParam.level_index ne '0' and bean.eval_grade_0 eq item}">
											<span class="bul-red bul-sm"></span>
										</c:if>
										<c:if test="${inputParam.level_index ne '1' and bean.eval_grade_1 eq item}">
											<span class="bul-blue bul-sm"></span>
										</c:if>
										<c:if test="${inputParam.level_index ne '2' and bean.eval_grade_2 eq item}">
											<span class="bul-green bul-sm"></span>
										</c:if>
										<c:if test="${inputParam.level_index ne '3' and bean.eval_grade_3 eq item}">
											<span class="bul-yellow bul-sm"></span>
										</c:if>
									</div>
									<div class="form-check form-check-inline">
										<c:if test="${item lt 9}">
											<label class="form-check-label mr5" for="${bean.maker_hr_svc_cd}${item}">${bean[key]}</label>
											<input class="form-check-input" type="radio" id="${bean.maker_hr_svc_cd}${item}" name="${bean.maker_hr_svc_cd}" value="${item}" ${bean.sel_val eq item ? 'checked=checked' : ''}>
										</c:if>
									</div>
								</div>
							</td>
						</c:forEach>
					</tr>

					<tr>
						<td class="text-center">보겔</td>
						<c:set var="bean" value="${evalMap['101']}"/>
						<td class="text-right" name="${bean.maker_hr_svc_cd}_eval_amt" id="${bean.maker_hr_svc_cd}_eval_amt"></td>
						<td class="text-center">
							<button type="button" class="btn btn-primary-gra" onclick="javascript:fnReset('${bean.maker_hr_svc_cd}');">초기화</button>
						</td>
						<c:forEach var="item" begin="1" end="18">
							<c:set var="key">level_${item}</c:set>
							<td>
								<div class="level-state">
									<div class="state-bul ${bean.show_yn eq 'N' ? 'invisible' : '' }">
										<!-- 상태표시가 없을 경우 "invisible" 클래스 추가-->
										<c:if test="${inputParam.level_index ne '0' and bean.eval_grade_0 eq item}">
											<span class="bul-red bul-sm"></span>
										</c:if>
										<c:if test="${inputParam.level_index ne '1' and bean.eval_grade_1 eq item}">
											<span class="bul-blue bul-sm"></span>
										</c:if>
										<c:if test="${inputParam.level_index ne '2' and bean.eval_grade_2 eq item}">
											<span class="bul-green bul-sm"></span>
										</c:if>
										<c:if test="${inputParam.level_index ne '3' and bean.eval_grade_3 eq item}">
											<span class="bul-yellow bul-sm"></span>
										</c:if>
									</div>
									<div class="form-check form-check-inline">
										<c:if test="${item lt 9}">
											<label class="form-check-label mr5" for="${bean.maker_hr_svc_cd}${item}">${bean[key]}</label>
											<input class="form-check-input" type="radio" id="${bean.maker_hr_svc_cd}${item}" name="${bean.maker_hr_svc_cd}" value="${item}" ${bean.sel_val eq item ? 'checked=checked' : ''}>
										</c:if>
									</div>
								</div>
							</td>
						</c:forEach>
					</tr>

					<tr>
						<td class="text-center">클리만</td>
						<c:set var="bean" value="${evalMap['105'] }"/>
						<td class="text-right" name="${bean.maker_hr_svc_cd}_eval_amt" id="${bean.maker_hr_svc_cd}_eval_amt"></td>
						<td class="text-center">
							<button type="button" class="btn btn-primary-gra" onclick="javascript:fnReset('${bean.maker_hr_svc_cd}');">초기화</button>
						</td>
						<c:forEach var="item" begin="1" end="18">
							<c:set var="key">level_${item}</c:set>
							<td>
								<div class="level-state">
									<div class="state-bul ${bean.show_yn eq 'N' ? 'invisible' : '' }">
										<!-- 상태표시가 없을 경우 "invisible" 클래스 추가-->
										<c:if test="${inputParam.level_index ne '0' and bean.eval_grade_0 eq item}">
											<span class="bul-red bul-sm"></span>
										</c:if>
										<c:if test="${inputParam.level_index ne '1' and bean.eval_grade_1 eq item}">
											<span class="bul-blue bul-sm"></span>
										</c:if>
										<c:if test="${inputParam.level_index ne '2' and bean.eval_grade_2 eq item}">
											<span class="bul-green bul-sm"></span>
										</c:if>
										<c:if test="${inputParam.level_index ne '3' and bean.eval_grade_3 eq item}">
											<span class="bul-yellow bul-sm"></span>
										</c:if>
									</div>
									<div class="form-check form-check-inline">
										<c:if test="${item lt 9}">
											<label class="form-check-label mr5" for="${bean.maker_hr_svc_cd}${item}">${bean[key]}</label>
											<input class="form-check-input" type="radio" id="${bean.maker_hr_svc_cd}${item}" name="${bean.maker_hr_svc_cd}" value="${item}" ${bean.sel_val eq item ? 'checked=checked' : ''}>
										</c:if>
									</div>
								</div>
							</td>
						</c:forEach>
					</tr>

					</tbody>
				</table>
			</div>
			<!-- /폼테이블 -->
			<div class="btn-group mt10">
				<div class="right">
					<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="BOM_R"/></jsp:include>
				</div>
			</div>
		</div>
	</div>
	<!-- // 팝업 -->
</form>
</body>
</html>
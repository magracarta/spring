<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 회계 > 정산 > 위탁판매점월정산 > null > 기타비용관리
-- 작성자 : 황빛찬
-- 최초 작성일 : 2020-04-08 18:03:57
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
	<script type="text/javascript">

		$(document).ready(function() {
			// AUIGrid 생성
			createAUIGrid();

			// 초기 저장시 수납월을 등록하지않음. 빈값세팅
			$M.setValue("pay_mon_year", "");
			$M.setValue("pay_mon_mon", "");
		});

		//그리드생성
		function createAUIGrid() {
			var gridPros = {
				rowIdField : "_$uid",
				// No. 제거
				showRowNumColumn: true,
				editable : false,
				fillColumnSizeMode : false,
				enableFilter :true,
				enableMovingColumn : false
			};
			var columnLayout = [
				{
					dataField : "org_etc_amt_seq",
					visible : false
				},
				{
					dataField : "org_code",
					visible : false
				},
				{
					headerText : "관리부서",
					dataField : "org_name",
					width : "14%",
					style : "aui-center aui-popup",
					filter : {
						showIcon : true
					}
				},
				{
					headerText : "비고",
					dataField : "remark",
					style : "aui-left"
				},
				{
					headerText : "시작연월",
					dataField : "start_mon",
					width : "14%",
					dataType : "date",
					formatString : "yyyy-mm",
					style : "aui-center",
				},
				{
					headerText : "종료연월",
					dataField : "end_mon",
					width : "14%",
					dataType : "date",
					formatString : "yyyy-mm",
					style : "aui-center",
				},
				{
					headerText : "월처리액",
					dataField : "use_amt",
					width : "14%",
					dataType : "numeric",
					formatString : "#,##0",
					style : "aui-right",
				},
				{
					headerText : "수납월",
					dataField : "pay_mon",
					width : "14%",
					dataType : "date",
					formatString : "yyyy-mm",
					style : "aui-center"
				}
			];

			auiGrid = AUIGrid.create("#auiGrid", columnLayout, gridPros);
			AUIGrid.setGridData(auiGrid, ${list});
			$("#auiGrid").resize();
			$("#total_cnt").html(AUIGrid.getGridData(auiGrid).length);

			AUIGrid.bind(auiGrid, "cellClick", function(event) {
				if (event.dataField == "org_name") {
					console.log("event : ", event);
					$M.setValue("org_etc_amt_seq", event.item.org_etc_amt_seq);
					$M.setValue("org_code", event.item.org_code);
					$M.setValue("org_name", event.item.org_name);
					$M.setValue("use_amt", event.item.use_amt);
					$M.setValue("remark", event.item.remark);
					$M.setValue("reg_date", event.item.reg_dt)
					$M.setValue("reg_mem_name", event.item.reg_mem_name)
					$M.setValue("vat_contain_yn", event.item.vat_contain_yn);

					var startDt = event.item.start_mon;  // 처리기간 시작일
					var endDt = event.item.end_mon;		// 처리기간 종료일
					var payDt = event.item.pay_mon;		// 수납일

					var endYear = endDt.substring(0, 4);  // 종료년
					var endMon = endDt.substring(4);	// 종료월
					var payYear = payDt.substring(0, 4);  // 수납년
					var payMon = payDt.substring(4);	// 수납월
					var startYear = startDt.substring(0, 4);  // 수납년
					var startMon = startDt.substring(4);	// 수납월

					// 잔액 공식 : 종료월 + (12 - 수납월) + 1 + (종료년 - 수납년 - 1) * 12 -1;
					var calc = Number(endMon) + (12 - Number(payMon)) + 1 + (Number(endYear) - Number(payYear) - 1) * 12 - 1;
					// 잔액 : 월처리액 * 잔액공식
					var balanceAmt = Number(event.item.use_amt) * calc;

					$M.setValue("total_amt", event.item.use_amt);
					$M.setValue("balance_amt", balanceAmt);

					// 처리기간 시작일 세팅
					$M.setValue("start_mon_year", startYear);
					$M.setValue("start_mon_mon", monCalc(startMon));

					// 처리기간 종료일 세팅
					$M.setValue("end_mon_year", endYear);
					$M.setValue("end_mon_mon", monCalc(endMon));

					// 수납월 세팅
					$M.setValue("pay_mon_year", payYear);
					$M.setValue("pay_mon_mon", monCalc(payMon));
				}
			});
		}

		// 월 계산기
		function monCalc(mon) {
        	if(mon.substring(0, 1) == 0) {
        		mon = mon.substring(1);
			}

        	return mon;
		}

		// 닫기
		function fnClose() {
			window.close();
		}

		// 저장
		function goSave() {
			var seq = $M.getValue("org_etc_amt_seq");
			if (seq == "") {
				$M.setValue("cmd", "C");
			}

			var startDt = fnSetDate($M.getValue("start_mon_year"), $M.getValue("start_mon_mon"));
			var endDt = fnSetDate($M.getValue("end_mon_year"), $M.getValue("end_mon_mon"));
			var payDt = fnSetDate($M.getValue("pay_mon_year"), $M.getValue("pay_mon_mon"));

			$M.setValue("start_mon", startDt);
			$M.setValue("end_mon", endDt);
// 			$M.setValue("pay_mon", payDt);

			var frm = document.main_form;

			// 입력폼 벨리데이션
			if($M.validation(frm) == false) {
				return;
			}

			frm = $M.toValueForm(frm);

			console.log("frm : ", frm);

			if (confirm("저장하시겠습니까?") == false) {
				return false;
			}

			$M.goNextPageAjax(this_page + "/save", frm , {method : 'POST'},
				function(result) {
		    		if(result.success) {
		    			alert("저장이 완료되었습니다.");
		    			fnClose();
		    			if(opener != null && opener.goSearch) {
			    			opener.goSearch();
		    			}
// 		    			window.opener.location.reload();
					}
				}
			);
		}

		function fnSetDate(year, mon) {
        	if(mon.length == 1) {
        		mon = "0" + mon;
			}
        	var sYearMon = year + mon;

        	return $M.dateFormat($M.toDate(sYearMon), 'yyyyMM');
		}

		// 삭제
		function goRemove() {
			var orgEtcAmtSeq = $M.getValue("org_etc_amt_seq");
			console.log("orgEtcAmtSeq : ", orgEtcAmtSeq);

			if (orgEtcAmtSeq == "") {
				alert("항목을 선택해 주세요.");
				return;
			}

			if (confirm("삭제하시겠습니까?") == false) {
				return false;
			}

			$M.goNextPageAjax(this_page + "/remove/" + orgEtcAmtSeq , "" , {method : 'POST'},
				function(result) {
		    		if(result.success) {
		    			alert("삭제 처리 되었습니다.");
		    			fnClose();
					}
				}
			);
		}

		// 대리점 조회 팝업
		function setOrgMapAgencyPanel(result) {
			$M.setValue("org_code", result.org_code);
			$M.setValue("org_name", result.org_name);
		}

		// 조회
		function goSearch() {
			var param = {
					search_gubun_all : $M.getValue("search_gubun_all"),  // 전체보기
					search_gubun_mon : $M.getValue("search_gubun_mon")   // 수납월
				};

			$M.goNextPageAjax(this_page + "/search", $M.toGetParam(param), {method : 'get'},
				function(result) {
					if(result.success) {
						$("#total_cnt").html(result.total_cnt);
						AUIGrid.setGridData(auiGrid, result.list);
					};
				}
			);
		}
	</script>
</head>
<body class="bg-white">
<form id="main_form" name="main_form">
<input type="hidden" id="org_etc_amt_seq" name="org_etc_amt_seq">
<!-- 팝업 -->
    <div class="popup-wrap width-100per">
<!-- 타이틀영역 -->
        <div class="main-title">
            <jsp:include page="/WEB-INF/jsp/common/menuNavi.jsp"/>
        </div>
<!-- /타이틀영역 -->
        <div class="content-wrap">
<!-- 폼테이블 -->
			<div>
				<table class="table-border mt5">
					<colgroup>
						<col width="100px">
						<col width="">
						<col width="100px">
						<col width="">
					</colgroup>
					<tbody>
						<tr>
							<%-- [재호] Q&A : 17751 대리점 → 위탁판매점으로 텍스트 교체 --%>
							<%--<th class="text-right essential-item">대리점</th>--%>
							<th class="text-right essential-item">위탁판매점</th>
							<td>
								<div class="input-group width120px">
									<input type="text" class="form-control border-right-0" id="org_name" name="org_name" required="required" alt="위탁판매점" readonly>
									<input type="hidden" id="org_code" name="org_code">
									<button type="button" class="btn btn-icon btn-primary-gra" onclick="javascript:openOrgMapAgencyPanel('setOrgMapAgencyPanel');"><i class="material-iconssearch"></i></button>
								</div>
							</td>
							<th class="text-right essential-item">처리기간</th>
							<td>
								<div class="input-group width290px">
										<select class="form-control rb col-auto" id="start_mon_year" name="start_mon_year" required="required" alt="처리기간">
											<c:forEach var="i" begin="2000" end="${inputParam.s_current_year}" step="1">
												<option value="${i}" <c:if test="${i==inputParam.s_end_year}">selected</c:if>>${i}년</option>
											</c:forEach>
										</select>
										<select class="form-control rb col-auto" id="start_mon_mon" name="start_mon_mon" required="required" alt="처리기간">
											<c:forEach var="i" begin="1" end="12" step="1">
												<option value="<fmt:formatNumber value="${i}" minIntegerDigits="1"/>" <c:if test="${i==inputParam.s_end_mon}">selected</c:if>>${i}월</option>
											</c:forEach>
										</select>
								<div class="col-auto text-center">~</div>
									<select class="form-control rb col-auto" id="end_mon_year" name="end_mon_year" required="required" alt="처리기간">
										<c:forEach var="i" begin="2000" end="${inputParam.s_current_year}" step="1">
											<option value="${i}" <c:if test="${i==inputParam.s_end_year}">selected</c:if>>${i}년</option>
										</c:forEach>
									</select>
									<select class="form-control rb col-auto" id="end_mon_mon" name="end_mon_mon" required="required" alt="처리기간">
										<c:forEach var="i" begin="1" end="12" step="1">
											<option value="<fmt:formatNumber value="${i}" minIntegerDigits="1"/>" <c:if test="${i==inputParam.s_end_mon}">selected</c:if>>${i}월</option>
										</c:forEach>
									</select>
                                 </div>
<!-- 									<div class="input-group col-5 "> -->
<!-- 	                                 </div> -->
							</td>
						</tr>
						<tr>
							<th class="text-right essential-item">월처리액</th>
							<td>
								<div class="form-row inline-pd widthfix">
									<div class="col width140px">
										<input type="text" class="form-control rb text-right" format="decimal" datatype="int" id="use_amt" name="use_amt" required="required" alt="월처리액">
									</div>
									<div class="col width22px">원</div>
									<div class="col width140px">
										<select class="form-control rb" id="vat_contain_yn" name="vat_contain_yn">
											<option value="N">부가세없음(포함가)</option>
											<option value="Y">부가세있음(별도가)</option>
										</select>
									</div>
								</div>
							</td>
							<th class="text-right">수납월</th>
							<td>
<!-- 									<input type="text" class="form-control border-right-0 calDate" id="pay_mon" name="pay_mon" dateformat="yyyy-MM"> -->
								<div class="input-group width173px">
<!-- 									<select class="form-control rb" id="pay_mon_year" name="pay_mon_year" required="required" alt="수납월"> -->
<%-- 										<c:forEach var="i" begin="2000" end="${inputParam.s_current_year}" step="1"> --%>
<%-- 											<option value="${i}" <c:if test="${i==inputParam.s_end_year}">selected</c:if>>${i}년</option> --%>
<%-- 										</c:forEach> --%>
<!-- 									</select>			 -->
<!-- 									<select class="form-control rb" id="pay_mon_mon" name="pay_mon_mon" required="required" alt="수납월"> -->
<%-- 										<c:forEach var="i" begin="1" end="12" step="1"> --%>
<%-- 											<option value="<fmt:formatNumber value="${i}" minIntegerDigits="1"/>" <c:if test="${i==inputParam.s_end_mon}">selected</c:if>>${i}월</option> --%>
<%-- 										</c:forEach> --%>
<!-- 									</select>																 -->
									<select class="form-control" id="pay_mon_year" name="pay_mon_year" alt="수납월">
<%-- 										<c:if test="${not empty org_code}"> --%>
											<c:forEach var="i" begin="2000" end="${inputParam.s_current_year}" step="1">
												<option value="${i}" <c:if test="${i==inputParam.s_end_year}">selected</c:if>>${i}년</option>
											</c:forEach>
<%-- 										</c:if> --%>
									</select>
									<select class="form-control" id="pay_mon_mon" name="pay_mon_mon" alt="수납월">
<%-- 										<c:if test="${not empty org_code}"> --%>
											<c:forEach var="i" begin="1" end="12" step="1">
												<option value="<fmt:formatNumber value="${i}" minIntegerDigits="1"/>" <c:if test="${i==inputParam.s_end_mon}">selected</c:if>>${i}월</option>
											</c:forEach>
<%-- 										</c:if> --%>
									</select>
                                 </div>
							</td>
						</tr>
						<tr>
							<th class="text-right">합계</th>
							<td>
								<div class="form-row inline-pd widthfix">
									<div class="col width140px">
										<input type="text" class="form-control text-right" readonly format="decimal" datatype="int" id="total_amt" name="total_amt">
									</div>
									<div class="col width22px">원</div>
								</div>
							</td>
							<th class="text-right">등록일시</th>
							<td>
								<input type="text" class="form-control width120px" readonly id="reg_date" name="reg_date">
							</td>
						</tr>
						<tr>
							<th class="text-right">잔액</th>
							<td>
								<div class="form-row inline-pd widthfix">
									<div class="col width140px">
										<input type="text" class="form-control text-right" readonly format="decimal" datatype="int" id="balance_amt" name="balance_amt">
									</div>
									<div class="col width22px">원</div>
								</div>
							</td>
							<th class="text-right">담당자</th>
							<td>
								<input type="text" class="form-control width120px" readonly id="reg_mem_name" name="reg_mem_name">
							</td>
						</tr>
						<tr>
							<th class="text-right essential-item">적요</th>
							<td>
								<input type="text" class="form-control rb" id="remark" name="remark" required="required" alt="적요">
							</td>
							<th class="text-right">조회구분</th>
							<td>
								<div class="form-check form-check-inline">
									<input class="form-check-input" type="checkbox" id="search_gubun_all" name="search_gubun_all" value="Y" onclick="javascript:goSearch()">
									<label class="form-check-label" for="search_gubun_all">전체보기</label>
								</div>
								<div class="form-check form-check-inline">
									<input class="form-check-input" type="checkbox" id="search_gubun_mon" name="search_gubun_mon" value="Y" onclick="javascript:goSearch()">
									<label class="form-check-label" for="search_gubun_mon">수납월</label>
								</div>
							</td>
						</tr>
					</tbody>
				</table>
			</div>
<!-- /폼테이블 -->
<!-- 폼테이블2 -->
			<div>
				<div class="title-wrap mt10">
					<h4>처리내역</h4>
				</div>
				<div id="auiGrid" style="margin-top: 5px; height: 200px;"></div>
				<div class="btn-group mt10">
					<div class="left">
						총 <strong id="total_cnt" class="text-primary">0</strong>건
					</div>
					<div class="right">
						<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="BOM_R"/></jsp:include>
					</div>
				</div>
			</div>
<!-- /폼테이블2-->
        </div>
    </div>
<!-- /팝업 -->
</form>
</body>
</html>

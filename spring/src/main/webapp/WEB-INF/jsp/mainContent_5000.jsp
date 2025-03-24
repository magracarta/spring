<%@ page contentType="text/html;charset=utf-8" language="java"%><%@ include file="/WEB-INF/jsp/common/commonForAll.jsp" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %>
<!DOCTYPE html> 
	<script type="text/javascript">
		var auiGridMidLeft;
		var auiGridMidRight;
		var auiGridBom;
		
		$(document).ready(function() {
			// AUIGrid 생성
			createAUIGridMidLeft();
			createAUIGridMidRight();
			createAUIGridBom();
		});
	
		function createAUIGridMidLeft() {
			var gridPros = {
				showRowNumColumn : true,
				rowIdField : "_$uid",
			};
			
			var columnLayout = [
				{ 
					headerText : "메이커", 
					dataField : "maker_name", 
					width : "9%",
					style : "aui-center",
					editable : false,
				},
				{ 
					headerText : "모델명", 
					dataField : "machine_name", 
					width : "14%",
					style : "aui-center",
					editable : false
				},
				{ 
					headerText : "고객명", 
					dataField : "cust_name", 
					width : "14%",
					style : "aui-center",
					editable : false,
				},
				{
					headerText : "휴대폰", 
					dataField : "hp_no", 
					width : "16%",
					style : "aui-center",
				},
				{
					headerText : "렌탈시작", 
					dataField : "rental_st_dt", 
					width : "13%",
					style : "aui-center",
					dataType : "date",
					formatString : "yyyy-mm-dd",
				},
				{
					headerText : "렌탈종료", 
					dataField : "rental_ed_dt", 
					width : "13%",
					style : "aui-center",
					dataType : "date",
					formatString : "yyyy-mm-dd",
				},
				{
					headerText : "렌탈금액", 
					dataField : "rental_amt", 
					width : "12%",
					style : "aui-right",
					dataType : "numeric",
					formatString : "#,##0",
				},
				{
					headerText : "연장시작", 
					dataField : "extend_st_dt", 
					width : "13%",
					style : "aui-center",
					dataType : "date",
					formatString : "yyyy-mm-dd",
				},
				{
					headerText : "연장종료", 
					dataField : "extend_ed_dt", 
					width : "13%",
					style : "aui-center",
					dataType : "date",
					formatString : "yyyy-mm-dd",
				},
				{
					headerText : "연장금액", 
					dataField : "extend_amt", 
					width : "12%",
					style : "aui-right",
					dataType : "numeric",
					formatString : "#,##0",
				},
				{
					headerText : "상태", 
					dataField : "rental_status_cd", 
					width : "8%",
					style : "aui-center",
				},
			];
			
			// 실제로 #grid_wrap에 그리드 생성
			auiGridMidLeft = AUIGrid.create("#auiGridMidLeft", columnLayout, gridPros);
			// 그리드 갱신
			AUIGrid.setGridData(auiGridMidLeft, ${servList1});
			AUIGrid.bind(auiGridMidLeft, "cellClick", function(event) {
				if(event.dataField == 'file_yn') {
					alert("차대번호 팝업입니다.");
				}
			}); 
		}
		
		// 제외부품 그리드
		function createAUIGridMidRight() {
			var gridPros = {
					showRowNumColumn : true,
					rowIdField : "_$uid",
			};
			
			var columnLayout = [
				{ 
					headerText : "센터", 
					dataField : "org_name", 
					width : "10%",
					style : "aui-center",
					editable : false,
				},
				{ 
					headerText : "분류", 
					dataField : "misu_gubun", 
					width : "8%",
					style : "aui-center",
					editable : false
				},
				{ 
					headerText : "구분", 
					dataField : "misu_type",
					width : "8%",
					style : "aui-center",
					editable : false,
				},
				{ 
					headerText : "고객명", 
					dataField : "cust_name",
					width : "9%",
					style : "aui-center",
					editable : false,
				},
				{ 
					headerText : "휴대폰", 
					dataField : "hp_no", 
					width : "16%",
					style : "aui-center",
					editable : false,
				},
				{
					headerText : "총미수금액", 
					dataField : "misu_amt", 
					width : "13%",
					style : "aui-right",
					dataType : "numeric",
					formatString : "#,##0",
				},
				{
					headerText : "미수담당자", 
					dataField : "misu_mem_name", 
					width : "9%",
					style : "aui-center",
				},
				{
					headerText : "미수처리접촉일", 
					dataField : "misu_proc_meet_dt", 
					width : "13%",
					style : "aui-center",
					dataType : "date",
					formatString : "yyyy-mm-dd",
				},
				{
					headerText : "마지막거래일", 
					dataField : "last_deal_dt", 
					width : "13%",
					style : "aui-center",
					dataType : "date",
					formatString : "yyyy-mm-dd",
				},
				{
					headerText : "거래원장메모", 
					dataField : "last_memo", 
					style : "aui-left",
				},
				{
					headerText : "입금예정일", 
					dataField : "deposit_plan_dt", 
					width : "13%",
					style : "aui-center",
					dataType : "date",
					formatString : "yyyy-mm-dd",
				}
			];

			// 실제로 #grid_wrap에 그리드 생성
			auiGridMidRight = AUIGrid.create("#auiGridMidRight", columnLayout, gridPros);
			// 그리드 갱신
			AUIGrid.setGridData(auiGridMidRight, ${servList2});
		}
		
		function createAUIGridBom() {
			var gridPros = {
					showRowNumColumn : true,
					rowIdField : "_$uid",
			};
			
			var columnLayout = [
				{ 
					headerText : "고객명", 
					dataField : "cust_name", 
					width : "9%",
					style : "aui-center",
					editable : false,
				},
				{ 
					headerText : "고객등급", 
					dataField : "cust_grade_cd",
					width : "8%",
					style : "aui-center",
					editable : false,
				},
				{ 
					headerText : "휴대폰", 
					dataField : "hp_no", 
					width : "16%",
					style : "aui-center",
					editable : false,
				},
				{
					headerText : "부서", 
					dataField : "org_name", 
					width : "10%",
					style : "aui-center",
				},
				{
					headerText : "상담모델", 
					dataField : "machine_name", 
					width : "12%",
					style : "aui-center",
				},
				{
					headerText : "사용년수", 
					dataField : "use_times", 
					style : "aui-center",
				},
				{
					headerText : "최근정비일자", 
					dataField : "repair_finish_dt", 
					width : "13%",
					style : "aui-center",
					dataType : "date",
					formatString : "yyyy-mm-dd",
				},
				{
					headerText : "가동시간", 
					dataField : "op_hour", 
					width : "8%",
					style : "aui-center",
				},
				{
					headerText : "미결일자", 
					dataField : "consult_dt", 
					width : "13%",
					style : "aui-center",
					dataType : "date",
					formatString : "yyyy-mm-dd",
				},
			];
				
			// 실제로 #grid_wrap에 그리드 생성
			auiGridBom = AUIGrid.create("#auiGridBom", columnLayout, gridPros);
			// 그리드 갱신
			AUIGrid.setGridData(auiGridBom, ${servList3});
		}
	</script>

						<div class="row">
							<div class="col-6">
								<div class="title-wrap mt10">
									<h4>렌탈회수예정건
										<span class="text-warning">※(성능개선 후 표기됨)</span> 
									</h4>
									<button type="button" class="btn btn-default" onclick="javascript:goMain('렌탈출고/회수현황', '/rent/rent0102');"><i class="material-iconskeyboard_arrow_right text-default"></i>바로가기</button>
								</div>
								<div id="auiGridMidLeft" style="margin-top: 5px; height: 250px;"></div>
							</div>
							<div class="col-6">
								<div class="title-wrap mt10">
									<h4>고객미수
										<span class="text-warning">※(성능개선 후 표기됨)</span> 
									</h4>
									<button type="button" class="btn btn-default" onclick="javascript:goMain('센터별미수현황', '/cust/cust0204');"><i class="material-iconskeyboard_arrow_right text-default"></i>바로가기</button>
								</div>
								<div id="auiGridMidRight" style="margin-top: 5px; height: 250px;"></div>
							</div>
						</div>
						<div class="row">
							<div class="col-6">
								<div class="title-wrap mt10">
									<h4>고객상담예정안건
										<span class="text-warning">※(성능개선 후 표기됨)</span> 
									</h4>
									<button type="button" class="btn btn-default" onclick="javascript:goMain('마케팅대상고객', '/cust/cust0101');"><i class="material-iconskeyboard_arrow_right text-default"></i>바로가기</button>
								</div>
								<div id="auiGridBom" style="margin-top: 5px; height: 250px;"></div>
							</div>
							<div class="col-6">
								<div class="title-wrap mt10">
									<h4><span class="text-primary">${SecureUser.kor_name}</span>님 당월 개인실적 (합계 :17,000,000)</h4>
								</div>
								<div class="mt7 pl10">
									<img src="/static/img/google-analytics.jpg" alt="구글애널리틱스 영역" style="width: 100%;">
								</div>
							</div>
						</div>
